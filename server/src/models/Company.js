const { DataTypes } = require('sequelize');
const sequelize = require('../config/connection');

const Company = sequelize.define('Company', {
    id: {
        type: DataTypes.UUID,
        defaultValue: DataTypes.UUIDV4,
        primaryKey: true,
    },
    company_name: {
        type: DataTypes.STRING(100),
        allowNull: false,
    },
    contact_email: {
        type: DataTypes.STRING(50),
        allowNull: false,
        unique: true,
    },
    contact_phone: {
        type: DataTypes.STRING(20),
        allowNull: false,
    },
    address: {
        type: DataTypes.TEXT,
        allowNull: false,
    },
}, {
    timestamps: true,
    createdAt: 'created_at',
    updatedAt: false,
});

module.exports = Company;
