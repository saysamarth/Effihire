const express = require('express');
const { syncDatabase } = require('./src/scripts/sync');

const app = express();

// Middleware
app.use(express.json());

// Basic health check
app.get('/health', async (req, res) => {
    try {
        const sequelize = require('./src/config/connection');
        await sequelize.authenticate();
        res.json({ status: 'OK', message: 'Database connected' });
    } catch (error) {
        res.status(500).json({ status: 'ERROR', message: 'Database connection failed' });
    }
});

// User routes
app.get('/users', async (req, res) => {
    try {
        const User = require('./src/models/User');
        const users = await User.findAll({
            include: ['bankDetails', 'taskApplications']
        });
        res.json(users);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch users', details: error.message });
    }
});

app.post('/users', async (req, res) => {
    try {
        const User = require('./src/models/User');
        const { mobile_number} = req.body;

        if (!mobile_number) {
            return res.status(400).json({ error: 'Mobile number is required' });
        }

        const user = await User.create({
            mobile_number,
        });

        res.status(201).json(user);
    } catch (error) {
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
        res.status(500).json({ error: 'Failed to fetch user', details: error.message });
    }
});

// Check if user exists by mobile number
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
        res.status(500).json({ error: 'Failed to check user', details: error.message });
    }
});

// Route to upload document URLs for a user
app.patch('/users/:id/documents', async (req, res) => {
    try {
        const User = require('./src/models/User');
        const { aadhar_url, dl_url, pan_url } = req.body;
        const userId = req.params.id;

        // Find user first
        const user = await User.findByPk(userId);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Update document URLs
        const updateData = {};
        if (aadhar_url) updateData.aadhar_url = aadhar_url;
        if (dl_url) updateData.dl_url = dl_url;
        if (pan_url) updateData.pan_url = pan_url;

        await user.update(updateData);
        res.json({ message: 'Document URLs updated successfully', user });
    } catch (error) {
        res.status(500).json({ error: 'Failed to update document URLs', details: error.message });
    }
});

// Route to complete personal registration and update registration_status to 1
app.patch('/users/:id/complete-personal-registration', async (req, res) => {
    try {
        const User = require('./src/models/User');
        const userId = req.params.id;
        const updateFields = req.body;

        const user = await User.findByPk(userId);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Fields required to already exist (saved earlier)
        const mustAlreadyExist = [
            'mobile_number',
            'aadhar_url',
            'dl_url',
            'pan_url'
        ];

        // Fields required in this request body
        const mustBeInBody = [
            'full_name',
            'current_address',
            'permanent_address',
            'vehicle_details',
            'aadhar_number',
            'driving_license',
            'pan_card'
        ];

        // Check if all mustAlreadyExist fields are present in DB
        const missingFromDB = mustAlreadyExist.filter(
            key => !user[key] || user[key].toString().trim() === ''
        );

        // Check if all mustBeInBody fields are present in req.body
        const missingFromBody = mustBeInBody.filter(
            key => !updateFields[key] || updateFields[key].toString().trim() === ''
        );

        if (missingFromDB.length > 0 || missingFromBody.length > 0) {
            return res.status(400).json({
                error: 'All required fields must be completed before registration',
                missing_fields: [...missingFromDB, ...missingFromBody]
            });
        }

        // Update DB with incoming body fields + set registration_status = 1
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
        res.status(500).json({ error: 'Failed to complete personal registration', details: error.message });
    }
});

// Route to toggle user online status
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
        res.status(500).json({ error: 'Failed to update online status', details: error.message });
    }
});

// Route to update registration status to 3 (police verification completed)
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
        res.status(500).json({ error: 'Failed to complete police verification', details: error.message });
    }
});

// Bank Details routes
app.get('/bank-details', async (req, res) => {
    try {
        const BankDetails = require('./src/models/BankDetails');
        const bankDetails = await BankDetails.findAll({
            include: ['user']
        });
        res.json(bankDetails);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch bank details', details: error.message });
    }
});

// Modified to update registration_status to 2 when bank details are created
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
        res.status(500).json({ error: 'Failed to create bank details', details: error.message });
    }
});

// Company routes
app.get('/companies', async (req, res) => {
    try {
        const Company = require('./src/models/Company');
        const companies = await Company.findAll({
            include: ['tasks']
        });
        res.json(companies);
    } catch (error) {
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
        res.status(500).json({ error: 'Failed to fetch company', details: error.message });
    }
});

// Task routes
app.get('/tasks', async (req, res) => {
    try {
        const Task = require('./src/models/Task');
        const tasks = await Task.findAll({
            include: ['company', 'applications']
        });
        res.json(tasks);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch tasks', details: error.message });
    }
});

// Task Application routes
app.get('/task-applications', async (req, res) => {
    try {
        const TaskApplication = require('./src/models/TaskApplication');
        const applications = await TaskApplication.findAll({
            include: ['user', 'task', 'payment']
        });
        res.json(applications);
    } catch (error) {
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
        res.status(500).json({ error: 'Failed to create task application', details: error.message });
    }
});

// Payment routes
app.get('/payments', async (req, res) => {
    try {
        const Payment = require('./src/models/Payment');
        const payments = await Payment.findAll({
            include: ['taskApplication']
        });
        res.json(payments);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch payments', details: error.message });
    }
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({ error: 'Route not found' });
});

// Start server
syncDatabase()
    .then(() => {
        console.log('✅ Database synced');
        app.listen(3000, () => {
            console.log('🚀 Server running at http://localhost:3000');
            console.log('📋 Available routes:');
            console.log('  GET  /health - Health check');
            console.log('  GET  /users - Get all users');
            console.log('  POST /users - Create new user');
            console.log('  GET  /users/:id - Get user by ID');
            console.log('  PATCH /users/:id/documents - Upload document URLs');
            console.log('  PATCH /users/:id/complete-personal-registration - Complete personal registration');
            console.log('  PATCH /users/:id/toggle-online - Toggle user online status');
            console.log('  PATCH /users/:id/complete-police-verification - Complete police verification');
            console.log('  GET  /bank-details - Get all bank details');
            console.log('  POST /bank-details - Create bank details (updates registration_status to 2)');
            console.log('  GET  /companies - Get all companies');
            console.log('  GET  /companies/:id - Get company by ID');
            console.log('  GET  /tasks - Get all tasks');
            console.log('  GET  /task-applications - Get all task applications');
            console.log('  POST /task-applications - Create task application');
            console.log('  GET  /payments - Get all payments');
            console.log('  ?user_id=<uuid> - Required to check user online status');
        });
    })
    .catch(err => {
        console.error('❌ Failed to start server:', err);
        process.exit(1);
    });

module.exports = app;