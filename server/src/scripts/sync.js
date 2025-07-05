const sequelize = require('../config/connection');
const models = require('../models/associations');

async function syncDatabase() {
    try {
        await sequelize.authenticate();
        console.log('Database connection established successfully.');

        // Sync all models with their associations
        await sequelize.sync({ alter: true });
        console.log('All models synchronized successfully with associations.');

    } catch (error) {
        console.error('Unable to connect to the database:', error);
        process.exit(1);
    }
}

if (require.main === module) {
    syncDatabase();
}

module.exports = { syncDatabase };