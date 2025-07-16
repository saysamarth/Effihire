const { DataTypes } = require('sequelize');
const sequelize = require('../config/connection');

const User = sequelize.define('User', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    mobile_number: {
        type: DataTypes.STRING(10),
        allowNull: false,
        unique: true,
    },
    full_name: {
        type: DataTypes.STRING(100),
    },
    current_address: {
        type: DataTypes.TEXT,
    },
    permanent_address: {
        type: DataTypes.TEXT,
    },
    vehicle_details: {
        type: DataTypes.STRING,
        
    },
    aadhar_number: {
        type: DataTypes.STRING(12),
        unique: true,
    },
    driving_license: {
        type: DataTypes.STRING(15),
        unique: true,
    },
    pan_card: {
        type: DataTypes.STRING(10),
        unique: true,
    },
    is_online: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
    },
    aadhar_front_url: {
        type: DataTypes.TEXT,
        unique: true,
    },
    aadhar_back_url: {
        type: DataTypes.TEXT,
        unique: true,
    },
    dl_url: {
        type: DataTypes.TEXT,
        unique: true,
    },
    pan_url: {
        type: DataTypes.TEXT,
        unique: true,
    },
    user_image_url: {
        type: DataTypes.TEXT,
        unique: true,
    },
    registration_status: {
        type: DataTypes.INTEGER,
        defaultValue: 0,
        validate: {
            min: 0,
            max: 3
        },
        comment: "0: New User, 1: Personal Info Done, 2: Bank Info Done, 3: Police Verification done/Fully Registered"
    },
    qualification: {
        type: DataTypes.STRING,
    },
    languages: {
        type: DataTypes.STRING,
    },
    gender: {
        type: DataTypes.ENUM('male', 'female', 'other'),
    }
}, {
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: 'updated_at',
});

module.exports = User;