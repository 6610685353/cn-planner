const getSupabase = require('../config/supabase');

async function getGPAcred(uid) {
    const supabase = getSupabase();
    const { data, error } = await supabase
        .from('profiles')
        .select('gpax, earned_credits, gpa, this_sem_credits')
        .eq("user_id", uid);

    if(error) throw error;

    return data;
}

async function getThisSem(uid) {
    const supabase = getSupabase();
    const { data, error } = await supabase
        .from('UserRoadmap')
        .select(`year, semester, Subjects (subjectCode, subjectName, credits, su_grade)`)
        .eq("user_id", uid)
        .eq("status", "planned")

    if (error) throw error;

    return data;
} 

module.exports = {
    getGPAcred,
    getThisSem,
}