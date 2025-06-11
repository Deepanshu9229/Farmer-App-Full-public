
// Connect to MongoDB
// mongoose.connect(process.env.MONGODB_URI, { useNewUrlParser: true, useUnifiedTopology: true })
//     .then(() => console.log('MongoDB connected'))
//     .catch(err => console.log(err));
require('dotenv').config();
const mongoose = require('mongoose');


const connectDB = async () => {
    try {
        
        await mongoose.connect(process.env.MONGODB_URI)
         console.log('MongoDB connected successfully');
    }catch(err) {
        console.error('MongoDB connection failed:', err);
        process.exit(1);
    }

}

// const connectDB = async () => {
//     try {
//         await mongoose.connect(process.env.MONGODB_URI, {
//             useNewUrlParser: true,
//             useUnifiedTopology: true,
//         });
//          console.log('MongoDB connected successfully');
//     }catch {
//         console.error('MongoDB connection failed:', err);
//         process.exit(1);
//     }

// }

module.exports = connectDB;