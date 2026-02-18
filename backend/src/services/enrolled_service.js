const userEnrolledModel = require('../models/enrolled_model');

exports.getUserByUid = async (uid) => {
    const user = await userEnrolledModel.findByUid(uid);

    if (!user) {
        throw new Error('User not found');
    }

    return user;
}