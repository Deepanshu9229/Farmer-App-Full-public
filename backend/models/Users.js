const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    userType: { type: String, enum: ['farmer', 'secretary', 'admin'], required: true },
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
