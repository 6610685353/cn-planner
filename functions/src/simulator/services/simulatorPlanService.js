/**
 * simulatorPlanService.js
 * บันทึก / ดึง simulator plan ลง Supabase ตาราง simulatorplan
 *
 * Schema:
 *   id           bigint (auto)
 *   user_id      text
 *   year         integer
 *   semester     integer
 *   subject_id   bigint
 *   subject_code text
 *   subject_name text
 *   credits      integer
 *   status       text  ('pass' | 'fail' | 'enrolled')
 *   plan_type    text  ('Internship' | 'Coop' | 'Research')
 *   updated_at   timestamptz
 */

const getSupabase = require('../../config/supabase');

const VALID_PLAN_TYPES = ['Internship', 'Coop', 'Research'];

/**
 * บันทึกแผนการเรียนของ user ลง simulatorplan เฉพาะ plan_type ที่ระบุ
 * ลบข้อมูลเก่าเฉพาะ plan_type นั้นก่อน แล้ว insert ใหม่
 * ไม่กระทบ plan_type อื่น
 *
 * @param {string} uid
 * @param {Array<{
 *   year: number,
 *   semester: number,
 *   subject_id: number|null,
 *   subject_code: string,
 *   subject_name: string,
 *   credits: number,
 *   status: 'pass' | 'fail' | 'enrolled'
 * }>} planRows
 * @param {string} planType - 'Internship' | 'Coop' | 'Research'
 */
const savePlan = async (uid, planRows, planType) => {
  const supabase = getSupabase();

  if (!VALID_PLAN_TYPES.includes(planType)) {
    throw new Error(`Invalid plan_type: "${planType}". Must be one of: ${VALID_PLAN_TYPES.join(', ')}`);
  }

  // 1. ลบแผนเก่าเฉพาะ plan_type นี้เท่านั้น — ไม่แตะแผนอื่น
  const { error: deleteError } = await supabase
    .from('simulatorplan')
    .delete()
    .eq('user_id', uid)
    .eq('plan_type', planType);

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
    subject_id: row.subject_id ?? null,
    subject_code: row.subject_code,
    subject_name: row.subject_name ?? '',
    credits: row.credits ?? 0,
    status: row.status,
    plan_type: planType,
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
 * ดึงแผนการเรียนของ user กรองตาม plan_type (optional)
 * @param {string} uid
 * @param {string|null} planType - ถ้าระบุจะดึงเฉพาะ plan นั้น
 * @returns {Promise<Array>}
 */
const getPlan = async (uid, planType = null) => {
  const supabase = getSupabase();

  let query = supabase
    .from('simulatorplan')
    .select('*')
    .eq('user_id', uid)
    .order('year', { ascending: true })
    .order('semester', { ascending: true });

  if (planType) {
    query = query.eq('plan_type', planType);
  }

  const { data, error } = await query;

  if (error) {
    console.error('simulatorPlanService getPlan error:', error.message);
    throw error;
  }

  return data ?? [];
};

/**
 * ลบแผนการเรียนของ user เฉพาะ plan_type ที่ระบุ
 * ถ้าไม่ระบุ plan_type จะลบทั้งหมด (ใช้สำหรับ admin/reset เท่านั้น)
 * @param {string} uid
 * @param {string|null} planType
 */
const deletePlan = async (uid, planType = null) => {
  const supabase = getSupabase();

  let query = supabase
    .from('simulatorplan')
    .delete()
    .eq('user_id', uid);

  if (planType) {
    if (!VALID_PLAN_TYPES.includes(planType)) {
      throw new Error(`Invalid plan_type: "${planType}"`);
    }
    query = query.eq('plan_type', planType);
  }

  const { error } = await query;

  if (error) {
    console.error('simulatorPlanService deletePlan error:', error.message);
    throw error;
  }

  return { deleted: true };
};

module.exports = { savePlan, getPlan, deletePlan };