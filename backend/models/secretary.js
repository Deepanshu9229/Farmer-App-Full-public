const mongoose = require('mongoose');

const secretarySchema = new mongoose.Schema({
    name : {type : String , required : true},
    mobileNumber : { type: String, required: true , unique: true} , 
    city : { type: String, required: true } , 
    pincode : { type: String, required: true } , 
    residentialAddress : { type: String, required: true } , 
    areaInControl : {
        pinCode : {type : String , required : true} , 
        areaName : {type : String , required : true} 
    } ,
}, { timestamps: true });

const Secretary = mongoose.model('Secretary' , secretarySchema);
module.exports = Secretary;