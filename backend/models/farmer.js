const mongoose = require('mongoose');

const farmerSchema = new mongoose.Schema({
    name: { type: String, required: true },
    mobileNumber : {type : String , required : true , unique : true},
    city : {type : String , required : true},
    pincode : {type : String , required : true} , 
    residentialAddress: { type: String, required: true },
    farms: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Farm' }], // Reference to the Farm model
}, { timestamps: true }); // Adding timestamps for createdAt and updatedAt

const Farmer = mongoose.model('Farmer', farmerSchema);
module.exports = Farmer;
