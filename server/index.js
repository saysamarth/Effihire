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
        const { mobile_number, full_name } = req.body;

        if (!mobile_number) {
            return res.status(400).json({ error: 'Mobile number is required' });
        }

        const user = await User.create({
            mobile_number,
            full_name: full_name || null
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

app.post('/bank-details', async (req, res) => {
    try {
        const BankDetails = require('./src/models/BankDetails');
        const { user_id, account_number, ifsc_code, bank_name, branch_name } = req.body;

        if (!user_id || !account_number || !ifsc_code) {
            return res.status(400).json({
                error: 'User ID, account number, and IFSC code are required'
            });
        }

        const bankDetails = await BankDetails.create({
            user_id,
            account_number,
            ifsc_code,
            bank_name,
            branch_name
        });

        res.status(201).json(bankDetails);
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

app.post('/companies', async (req, res) => {
    try {
        const Company = require('./src/models/Company');
        const { company_name, contact_email, contact_phone, address } = req.body;

        if (!company_name || !contact_email || !contact_phone || !address) {
            return res.status(400).json({
                error: 'Company name, contact email, contact phone, and address are required'
            });
        }

        const company = await Company.create({
            company_name,
            contact_email,
            contact_phone,
            address
        });

        res.status(201).json(company);
    } catch (error) {
        res.status(500).json({ error: 'Failed to create company', details: error.message });
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

app.post('/tasks', async (req, res) => {
    try {
        const Task = require('./src/models/Task');
        const {
            company_id,
            title,
            job_role,
            offered_amount,
            location,
            location_coordinate,
            required_number_of_workers,
            expires_at
        } = req.body;

        if (!company_id || !title || !job_role || !offered_amount || !location || !location_coordinate || !required_number_of_workers) {
            return res.status(400).json({
                error: 'All required fields must be provided'
            });
        }

        const task = await Task.create({
            company_id,
            title,
            job_role,
            offered_amount,
            location,
            location_coordinate,
            required_number_of_workers,
            expires_at
        });

        res.status(201).json(task);
    } catch (error) {
        res.status(500).json({ error: 'Failed to create task', details: error.message });
    }
});

app.get('/tasks/:id', async (req, res) => {
    try {
        const Task = require('./src/models/Task');
        const task = await Task.findByPk(req.params.id, {
            include: ['company', 'applications']
        });

        if (!task) {
            return res.status(404).json({ error: 'Task not found' });
        }

        res.json(task);
    } catch (error) {
        res.status(500).json({ error: 'Failed to fetch task', details: error.message });
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
        const { task_id, user_id } = req.body;

        if (!task_id || !user_id) {
            return res.status(400).json({
                error: 'Task ID and User ID are required'
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

app.post('/payments', async (req, res) => {
    try {
        const Payment = require('./src/models/Payment');
        const { task_application_id, amount, payment_method } = req.body;

        if (!task_application_id || !amount) {
            return res.status(400).json({
                error: 'Task application ID and amount are required'
            });
        }

        const payment = await Payment.create({
            task_application_id,
            amount,
            payment_method
        });

        res.status(201).json(payment);
    } catch (error) {
        res.status(500).json({ error: 'Failed to create payment', details: error.message });
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
            console.log('  GET  /bank-details - Get all bank details');
            console.log('  POST /bank-details - Create bank details');
            console.log('  GET  /companies - Get all companies');
            console.log('  POST /companies - Create new company');
            console.log('  GET  /companies/:id - Get company by ID');
            console.log('  GET  /tasks - Get all tasks');
            console.log('  POST /tasks - Create new task');
            console.log('  GET  /tasks/:id - Get task by ID');
            console.log('  GET  /task-applications - Get all task applications');
            console.log('  POST /task-applications - Create task application');
            console.log('  GET  /payments - Get all payments');
            console.log('  POST /payments - Create payment');
        });
    })
    .catch(err => {
        console.error('❌ Failed to start server:', err);
        process.exit(1);
    });

module.exports = app;