const express = require('express');
const router = express.Router({ mergeParams: true });
const Pump = require('../../models/pump'); 
const Farm = require('../../models/farm');
const farms = require('../farmer/farms');

const mqtt = require('mqtt');
const client = mqtt.connect('mqtt://localhost/1883'); 

client.on('connect', () => {
    console.log('Connected to MQTT broker');
    
    // Subscribe to all pumps' status response topics for all farmers and farms
    client.subscribe('farmers/+/farms/+/pumps/+/status/response', (err) => {
        if (err) {
            console.log('Failed to subscribe to response topic');
        }
    });
    
    // Subscribe to all pumps' interval response topics for all farmers and farms
    client.subscribe('farmers/+/farms/+/pumps/+/interval/response', (err) => {
        if (err) {
            console.log('Failed to subscribe to interval topic');
        }
    });
});

client.on('message', (topic, message) => {
    console.log(`Received message on ${topic}: ${message.toString()}`);

    // Extract farmerId, farmId, pumpId from the topic
    const regex = /^farmers\/(.*?)\/farms\/(.*?)\/pumps\/(.*?)\/(status|interval)\/response$/;
    const match = topic.match(regex);

    if (match) {
        const farmerId = match[1];  
        const farmId = match[2];   
        const pumpId = match[3];   
        const type = match[4];      

        const response = JSON.parse(message.toString());
        console.log(`${type} response for ${farmerId} - ${farmId} - ${pumpId}:`, response);

        // Update pump status or interval in the database based on the response
        if (type === 'status') {
            const status = (response.status == 'on');
            Pump.findByIdAndUpdate(pumpId, { status }, { new: true })
                .then(updatedPump => {
                    console.log(`Updated pump status in database: ${updatedPump.status}`);
                })
                .catch(error => {
                    console.log('Failed to update pump status in database', error);
                });
        } else if (type === 'interval') {
            const interval = response.interval;
            Pump.findByIdAndUpdate(pumpId, { interval }, { new: true })
                .then(updatedPump => {
                    console.log(`Updated pump interval in database: ${updatedPump.interval}`);
                })
                .catch(error => {
                    console.log('Failed to update pump interval in database', error);
                });
        }
    }
});

router.get('/' ,  async (req , res) => {
    const farmId = req.params.farmId;
    console.log(farmId);
    try {
        const pumps = await Pump.find({ farmId: farmId});
        res.status(200).json(pumps);
    }catch (error){
        res.status(500).json({ error: 'Internal server error' });
    }
})

router.post('/add' , async (req, res) => {   
    const { pumpId } = req.body
    const farmId = req.params.farmId;
    console.log(farmId);
    try {
        const newPump = await Pump.create({
            pumpId ,
            farmId ,
            status : false , 
        });

        // await newPump.save();
        res.status(201).json({ message: 'Pump added successfully', pump: newPump });
    } catch (error) {
        res.status(500).json({ error: 'Internal server error' });
    }
});

router.delete('/:pumpId' , async (req , res) => {
    const farmId = req.params.farmId;
    const { pumpId } = req.params;
    try {
        const pump = await Pump.findOneAndDelete({ _id: pumpId, farmId });
         if (!pump) {
            return res.status(404).json({ message: 'Pump not found' });
        }
        res.status(200).json({ message: 'Pump deleted successfully' });
    }catch (error){
        res.status(500).json({ error: 'Internal server error' });
    }
})

router.post('/:pumpId/status' , async (req, res) => {
    const { status } = req.body;
    const { pumpId } = req.params;

   try {
        const pump = await Pump.findById(pumpId);
        if (!pump) {
            return res.status(404).json({ message: 'Pump not found' });
        }

        if (pump.status === status) {
            return res.status(200).json({ message: `Pump is already ${status ? 'on' : 'off'}` });
        }

        const topic = `farmers/${req.params.farmerId}/farms/${req.params.farmId}/pumps/${pumpId}/status`;
        const message = JSON.stringify({ status: status ? 'on' : 'off' });

        client.publish(topic, message, (err) => {
            if (err) {
                return res.status(500).json({ error: 'Failed to send MQTT message' });
            }
            res.status(200).json({ message: `Pump status changed to ${status ? 'on' : 'off'}`, pump });
        });
    } catch (error) {
        res.status(500).json({ error: 'Internal server error' });
    }
});

router.post('/:pumpId/interval' , async (req, res) => {
    const { interval } = req.body;
    const { pumpId } = req.params;

    
    try {
        const pump = await Pump.findById(pumpId);
        if (!pump) {
            return res.status(404).json({ message: 'Pump not found' });
        }
        
        await Pump.findByIdAndUpdate(pumpId, { interval }, { new: true });

        const topic = `farmers/${req.params.farmerId}/farms/${req.params.farmId}/pumps/${pumpId}/interval`;
        const message = JSON.stringify({ interval });

        client.publish(topic, message, (err) => {
            if (err) {
                return res.status(500).json({ error: 'Failed to send MQTT message' });
            }
            res.status(200).json({ message: 'Interval set successfully', pump });
        });
    } catch (error) {
        res.status(500).json({ error: 'Internal server error' });
    }
});

module.exports = router;