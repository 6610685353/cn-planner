const roadmapService = require('../services/roadmap_service')

//POST
const submitGrade = async (req, res) => {
    console.log("call submit grade controller");

    try {
        const { uid , gpax , credits , gpa, thisSemCred } = req.body;

        if (!uid) {
            return res.status(400).json({ message : "Invalid UID"});
        }

        console.log("Body", req.body);

        await roadmapService.submitGPAX(uid, gpax, credits, gpa, thisSemCred);
        console.log("controller updated")
        res.status(200).json({ message: "Submit successful"});
    } catch (err) {
        console.log(`Submit GPAX Error : ${err}`);
        res.status(500).json({ error: err.message });
    }
};

module.exports = {
    submitGrade,
}