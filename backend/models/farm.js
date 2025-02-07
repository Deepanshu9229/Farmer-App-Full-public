const mongoose = require('mongoose');

const farmSchema = new mongoose.Schema({
    name: { type: String, required: true },
    pincode : {type : String , required : true},
    location: { type: String, required: true },
    address: { type: String, required: true },
    farmerId: { type: mongoose.Schema.Types.ObjectId, ref: 'Farmer', required: true }, 
    pump : [{ type: mongoose.Schema.Types.ObjectId , ref: 'Pump' }]
}, { timestamps: true }); // Adding timestamps for createdAt and updatedAt

const Farm = mongoose.model('Farm', farmSchema);
module.exports = Farm;

