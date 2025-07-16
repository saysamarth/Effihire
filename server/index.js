const express = require('express');
const { syncDatabase } = require('./src/scripts/sync');

const app = express();

app.use((req, res, next) => {
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.path}`);
    next();
});

app.use(express.json());

app.use((err, req, res, next) => {
    if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
        console.error('JSON Parse Error:', err.message);
        return res.status(400).json({ error: 'Invalid JSON in request body' });
    }
    next();
});

process.on('uncaughtException', (err) => {
    console.error('Uncaught Exception:', err);
    console.error('Stack:', err.stack);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

app.get('/health', async (req, res) => {
    try {
        const sequelize = require('./src/config/connection');
        await sequelize.authenticate();
        res.json({ status: 'OK', message: 'Database connected' });
    } catch (error) {
        console.error('Database connection failed:', error.message);
        res.status(500).json({ status: 'ERROR', message: 'Database connection failed' });
    }
});

app.get('/users', async (req, res) => {
    try {
        const User = require('./src/models/User');
        const users = await User.findAll({
            include: ['bankDetails', 'taskApplications']
        });
        res.json(users);
    } catch (error) {
        console.error('Failed to fetch users:', error.message);
        res.status(500).json({ error: 'Failed to fetch users', details: error.message });
    }
});

app.post('/users', async (req, res) => {
    try {
        const User = require('./src/models/User');
        const { mobile_number } = req.body;

        if (!mobile_number) {
            return res.status(400).json({ error: 'Mobile number is required' });
        }

        const user = await User.create({
            mobile_number,
        });

        res.status(201).json(user);
    } catch (error) {
        console.error('Failed to create user:', error.message);
        res.status(500).json({ error: 'Failed to create user', details: error.message });
    }
});

app.get('/users/:id', async (req, res) => {
    try {
        const User = require('./src/models/User');
        const user = await User.findByPk(req.params.id, {
            include: ['bankDetails', 'taskApplications']
        });

        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        res.json(user);
    } catch (error) {
        console.error('Failed to fetch user:', error.message);
        res.status(500).json({ error: 'Failed to fetch user', details: error.message });
    }
});

app.get('/users/check/:mobile', async (req, res) => {
    try {
        const User = require('./src/models/User');
        const mobile_number = req.params.mobile;

        const user = await User.findOne({
            where: { mobile_number },
            include: ['bankDetails', 'taskApplications']
        });

        if (user) {
            res.json({ exists: true, user });
        } else {
            res.json({ exists: false });
        }
    } catch (error) {
        console.error('Failed to check user:', error.message);
        res.status(500).json({ error: 'Failed to check user', details: error.message });
    }
});

app.patch('/users/:id/complete-personal-registration', async (req, res) => {
    try {
        const User = require('./src/models/User');
        const userId = req.params.id;
        const updateFields = req.body;

        const user = await User.findByPk(userId);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }
        
        const mustAlreadyExist = [
            'mobile_number',
        ];

        const mustBeInBody = [
            'full_name',
            'current_address',
            'permanent_address',
            'vehicle_details',
            'aadhar_number',
            'qualification',
            'languages',
            'gender',
            'aadhar_front_url',
            'aadhar_back_url',
            'pan_url',
            'dl_url',
            'user_image_url',
            'aadhar_number',
            'pan_card',
        ];

        const missingFromDB = mustAlreadyExist.filter(
            key => !user[key] || user[key].toString().trim() === ''
        );

        const missingFromBody = mustBeInBody.filter(
            key => !updateFields[key] || updateFields[key].toString().trim() === ''
        );

        if (missingFromDB.length > 0 || missingFromBody.length > 0) {
            return res.status(400).json({
                error: 'All required fields must be completed before registration',
                missing_fields: [...missingFromDB, ...missingFromBody]
            });
        }

        await user.update({
            ...updateFields,
            registration_status: 1
        });

        res.json({
            message: 'Personal registration completed successfully',
            user,
            next_step: 'Please complete bank registration'
        });
    } catch (error) {
        console.error('Failed to complete personal registration:', error.message);
        res.status(500).json({ error: 'Failed to complete personal registration', details: error.message });
    }
});

app.patch('/users/:id/toggle-online', async (req, res) => {
    try {
        const User = require('./src/models/User');
        const userId = req.params.id;
        const { is_online } = req.body;

        const user = await User.findByPk(userId);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        await user.update({ is_online: is_online !== undefined ? is_online : !user.is_online });

        res.json({
            message: `User ${user.is_online ? 'online' : 'offline'} status updated`,
            user
        });
    } catch (error) {
        console.error('Failed to update online status:', error.message);
        res.status(500).json({ error: 'Failed to update online status', details: error.message });
    }
});

app.patch('/users/:id/complete-police-verification', async (req, res) => {
    try {
        const User = require('./src/models/User');
        const userId = req.params.id;

        const user = await User.findByPk(userId);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        if (user.registration_status !== 2) {
            return res.status(400).json({
                error: 'User must complete bank registration first',
                current_status: user.registration_status
            });
        }

        await user.update({ registration_status: 3 });

        res.json({
            message: 'Police verification completed successfully',
            user,
            status: 'User is now fully registered'
        });
    } catch (error) {
        console.error('Failed to complete police verification:', error.message);
        res.status(500).json({ error: 'Failed to complete police verification', details: error.message });
    }
});

app.get('/bank-details', async (req, res) => {
    try {
        const BankDetails = require('./src/models/BankDetails');
        const bankDetails = await BankDetails.findAll({
            include: ['user']
        });
        res.json(bankDetails);
    } catch (error) {
        console.error('Failed to fetch bank details:', error.message);
        res.status(500).json({ error: 'Failed to fetch bank details', details: error.message });
    }
});

app.post('/bank-details', async (req, res) => {
    try {
        const BankDetails = require('./src/models/BankDetails');
        const User = require('./src/models/User');
        const { user_id, account_number, ifsc_code, bank_name, branch_name } = req.body;

        if (!user_id || !account_number || !ifsc_code) {
            return res.status(400).json({
                error: 'User ID, account number, and IFSC code are required'
            });
        }

        const user = await User.findByPk(user_id);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        if (user.registration_status < 1) {
            return res.status(400).json({
                error: 'User must complete personal registration first'
            });
        }

        const bankDetails = await BankDetails.create({
            user_id,
            account_number,
            ifsc_code,
            bank_name,
            branch_name
        });

        await user.update({ registration_status: 2 });

        res.status(201).json({
            bankDetails,
            message: 'Bank details created successfully',
            next_step: 'Please complete police verification'
        });
    } catch (error) {
        console.error('Failed to create bank details:', error.message);
        res.status(500).json({ error: 'Failed to create bank details', details: error.message });
    }
});

app.get('/companies', async (req, res) => {
    try {
        const Company = require('./src/models/Company');
        const companies = await Company.findAll({
            include: ['tasks']
        });
        res.json(companies);
    } catch (error) {
        console.error('Failed to fetch companies:', error.message);
        res.status(500).json({ error: 'Failed to fetch companies', details: error.message });
    }
});

app.get('/companies/:id', async (req, res) => {
    try {
        const Company = require('./src/models/Company');
        const company = await Company.findByPk(req.params.id, {
            include: ['tasks']
        });

        if (!company) {
            return res.status(404).json({ error: 'Company not found' });
        }

        res.json(company);
    } catch (error) {
        console.error('Failed to fetch company:', error.message);
        res.status(500).json({ error: 'Failed to fetch company', details: error.message });
    }
});

app.get('/tasks', async (req, res) => {
    try {
        const Task = require('./src/models/Task');
        const tasks = await Task.findAll({
            include: ['company', 'applications']
        });
        res.json(tasks);
    } catch (error) {
        console.error('Failed to fetch tasks:', error.message);
        res.status(500).json({ error: 'Failed to fetch tasks', details: error.message });
    }
});

app.get('/task-applications', async (req, res) => {
    try {
        const TaskApplication = require('./src/models/TaskApplication');
        const applications = await TaskApplication.findAll({
            include: ['user', 'task', 'payment']
        });
        res.json(applications);
    } catch (error) {
        console.error('Failed to fetch task applications:', error.message);
        res.status(500).json({ error: 'Failed to fetch task applications', details: error.message });
    }
});

app.post('/task-applications', async (req, res) => {
    try {
        const TaskApplication = require('./src/models/TaskApplication');
        const User = require('./src/models/User');
        const { task_id, user_id } = req.body;

        if (!task_id || !user_id) {
            return res.status(400).json({
                error: 'Task ID and User ID are required'
            });
        }

        const user = await User.findByPk(user_id);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        if (!user.is_online) {
            return res.status(403).json({
                error: 'User must be online to apply for tasks'
            });
        }

        if (user.registration_status < 3) {
            return res.status(403).json({
                error: 'User must complete full registration to apply for tasks',
                current_status: user.registration_status
            });
        }

        const application = await TaskApplication.create({
            task_id,
            user_id
        });

        res.status(201).json(application);
    } catch (error) {
        console.error('Failed to create task application:', error.message);
        res.status(500).json({ error: 'Failed to create task application', details: error.message });
    }
});

app.get('/payments', async (req, res) => {
    try {
        const Payment = require('./src/models/Payment');
        const payments = await Payment.findAll({
            include: ['taskApplication']
        });
        res.json(payments);
    } catch (error) {
        console.error('Failed to fetch payments:', error.message);
        res.status(500).json({ error: 'Failed to fetch payments', details: error.message });
    }
});

app.use((req, res) => {
    res.status(404).json({ error: 'Route not found' });
});

app.use((err, req, res, next) => {
    console.error('Express Error Handler:', err.message);
    res.status(500).json({ error: 'Internal server error', details: err.message });
});

syncDatabase()
    .then(() => {
        console.log('Database synced successfully');
        const server = app.listen(3000, () => {
            console.log('Server running at http://localhost:3000');
        });

        server.on('error', (err) => {
            console.error('Server error:', err);
        });
    })
    .catch(err => {
        console.error('Failed to start server:', err);
        process.exit(1);
    });

module.exports = app;