const getSupabase = require('../config/supabase');

const submitGPAX = async (uid, gpax, credits) => {
    console.log("Calling GPAX submit Service")

    const supabase = getSupabase();

    const { error } = await supabase
        .from('profiles')
        .update({ gpax: gpax , earned_credits: credits})
        .eq('user_id', uid);

    if(error != null) {
        console.log(`Roadmap error : ${error}`);
    }
}

module.exports = {
    submitGPAX,
};