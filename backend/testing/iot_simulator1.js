const mqtt = require('mqtt');
const axios = require('axios'); 

const client = mqtt.connect('mqtt://localhost:1883'); 

const pumpId = '345335'; 
const farmerId = '1234567890';  
const farmId = '6725737634cd19ec88a6713c'; 

const statusTopic = `farmers/${farmerId}/farms/${farmId}/pumps/${pumpId}/status`;

async function getPumpStatusFromServer() {
    try {
        const response = await axios.get('http://localhost:4000/api/farmer/farms/6725737634cd19ec88a6713c/pumps/345335'); 
        return response.data.status;  
    } catch (error) {
        console.log('Error fetching pump status from server:', error);
        return null; 
    }
}

client.on('connect', () => {
    console.log('Connected to MQTT broker');

    client.subscribe(statusTopic, (err) => {
        if (err) {
            console.log('Failed to subscribe to `status topic');
        }
    });

    // Fetch pump status from the server and publish it to MQTT every 5 seconds
    setInterval(async () => {
        const status = await getPumpStatusFromServer(); 
        if (status) {
            const message = JSON.stringify({ status });
            client.publish(statusTopic, message, (err) => {
                if (err) {
                    console.log('Failed to send status message:', err);
                } else {
                    console.log(`Pump status: ${status} for pump ${pumpId}`);
                }
            });
        }
    }, 5000);
});

// Handle incoming status messages
client.on('message', (topic, message) => {
    if (topic === statusTopic) {
        const { status } = JSON.parse(message.toString());
        console.log(`Received pump status: ${status} for pump ${pumpId}`);
    }
});

client.on('error', (err) => {
    console.log('MQTT Client Error:', err);
});
