/**
 * simulatorPlanService.js
 * บันทึก / ดึง simulator plan ลง Supabase ตาราง simulatorplan
 *
 * Schema:
 *   id          bigint (auto)
 *   user_id     text
 *   year        integer
 *   semester    integer
 *   subject_id  bigint
 *   subject_code text
 *   status      text  ('pass' | 'fail')
 *   updated_at  timestamptz
 */

const getSupabase = require('../../config/supabase');

/**
 * บันทึกแผนการเรียนทั้งหมดของ user ลง simulatorplan
 * ลบข้อมูลเก่าของ user ก่อน แล้ว insert ใหม่ทั้งหมด
 *
 * @param {string} uid
 * @param {Array<{
 *   year: number,
 *   semester: number,
 *   subject_id: number,
 *   subject_code: string,
 *   status: 'pass' | 'fail'
 * }>} planRows
 */
const savePlan = async (uid, planRows) => {
  const supabase = getSupabase();

  // 1. ลบแผนเก่าทั้งหมดของ user
  const { error: deleteError } = await supabase
    .from('simulatorplan')
    .delete()
    .eq('user_id', uid);

  if (deleteError) {
    console.error('simulatorPlanService delete error:', deleteError.message);
    throw deleteError;
  }

  if (!planRows || planRows.length === 0) {
    return { saved: 0 };
  }

  // 2. เตรียม rows ให้ครบ field
  const rows = planRows.map((row) => ({
    user_id: uid,
    year: row.year,
    semester: row.semester,
    subject_id: row.subject_id,
    subject_code: row.subject_code,
    status: row.status, // 'pass' | 'fail'
    updated_at: new Date().toISOString(),
  }));

  // 3. Insert ทั้งหมด
  const { data, error: insertError } = await supabase
    .from('simulatorplan')
    .insert(rows)
    .select('id');

  if (insertError) {
    console.error('simulatorPlanService insert error:', insertError.message);
    throw insertError;
  }

  return { saved: data?.length ?? rows.length };
};

/**
 * ดึงแผนการเรียนของ user ทั้งหมด
 * @param {string} uid
 * @returns {Promise<Array>}
 */
const getPlan = async (uid) => {
  const supabase = getSupabase();

  const { data, error } = await supabase
    .from('simulatorplan')
    .select('*')
    .eq('user_id', uid)
    .order('year', { ascending: true })
    .order('semester', { ascending: true });

  if (error) {
    console.error('simulatorPlanService getPlan error:', error.message);
    throw error;
  }

  return data ?? [];
};

/**
 * ลบแผนการเรียนของ user ทั้งหมด
 * @param {string} uid
 */
const deletePlan = async (uid) => {
  const supabase = getSupabase();

  const { error } = await supabase
    .from('simulatorplan')
    .delete()
    .eq('user_id', uid);

  if (error) {
    console.error('simulatorPlanService deletePlan error:', error.message);
    throw error;
  }

  return { deleted: true };
};

module.exports = { savePlan, getPlan, deletePlan };
