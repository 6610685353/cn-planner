const userEnrolledService = require('../services/enrolled_service');

exports.getUserByUid = async (req, res, next) => {
    try {
        const user = await userEnrolledService.getUserByUid(req.params.id);
        res.status(200).json(user);
    } catch (error) {
        next(error);
    }
};