const mqtt = require('mqtt');
const axios = require('axios'); 

const client = mqtt.connect('mqtt://localhost:1883'); 

const pumpId = 'pump2'; 
const farmerId = '1234567899';  
const farmId = 'farm1'; 

const statusTopic = `farmers/${farmerId}/farms/${farmId}/pumps/${pumpId}/status`;

async function getPumpStatusFromServer() {
    try {
        // const response = await axios.get('http://localhost:3000/'); 
        const response = 'on';
        // return response.data.status;  
        return response;
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
