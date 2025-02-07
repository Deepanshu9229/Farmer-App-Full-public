const mongoose = require('mongoose');

const adminSchema = new mongoose.Schema({
    name: { type: String, required: true },
    mobileNumber: { type: String, required: true, unique: true },
    pincode : {type : String , required : true} , 
    residentialAddress: { type: String, required: true },
}, { timestamps: true });

const Admin = mongoose.model('Admin', adminSchema);
module.exports = Admin;
