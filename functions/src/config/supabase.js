const { createClient } = require('@supabase/supabase-js');

const getSupabase = () => {
    const supabaseURL = process.env.SUPABASE_URL;
    const supabaseKey = process.env.SUPABASE_ANON_KEY;

    if(!supabaseURL || !supabaseKey) {
        console.warn("Deployment analysis: Supabase failed");
        return null;
    }

    return createClient(supabaseURL, supabaseKey);
};

module.exports = getSupabase;