const User = require('./User');
const BankDetails = require('./BankDetails');
const Company = require('./Company');
const Task = require('./Task');
const TaskApplication = require('./TaskApplication');
const Payment = require('./Payment');
// Define associations
User.hasOne(BankDetails, {
    foreignKey: 'user_id',
    as: 'bankDetails',
});
BankDetails.belongsTo(User, {
    foreignKey: 'user_id',
    as: 'user',
});

Company.hasMany(Task, {
    foreignKey: 'company_id',
    as: 'tasks',
});
Task.belongsTo(Company, {
    foreignKey: 'company_id',
    as: 'company',
});

User.hasMany(TaskApplication, {
    foreignKey: 'user_id',
    as: 'taskApplications',
});
TaskApplication.belongsTo(User, {
    foreignKey: 'user_id',
    as: 'user',
});

Task.hasMany(TaskApplication, {
    foreignKey: 'task_id',
    as: 'applications',
});
TaskApplication.belongsTo(Task, {
    foreignKey: 'task_id',
    as: 'task',
});

TaskApplication.hasOne(Payment, {
    foreignKey: 'task_application_id',
    as: 'payment',
});
Payment.belongsTo(TaskApplication, {
    foreignKey: 'task_application_id',
    as: 'taskApplication',
});

module.exports = {
    User,
    BankDetails,
    Company,
    Task,
    TaskApplication,
    Payment,
};