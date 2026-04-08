/** @type {Array<{ id, name, createdAt, outcomes, notes }>} */
const store = [];
let counter = 1;

const save = ({ name, outcomes, notes = "" }) => {
  const record = {
    id:        counter++,
    name:      name || `Simulation #${counter - 1}`,
    createdAt: new Date().toISOString(),
    outcomes,
    notes,
  };
  store.push(record);
  return record;
};

const getAll = () =>
  store.map(({ id, name, createdAt, notes }) => ({ id, name, createdAt, notes }));

const getById = (id) => store.find((s) => s.id === Number(id)) ?? null;

const remove = (id) => {
  const idx = store.findIndex((s) => s.id === Number(id));
  if (idx === -1) return false;
  store.splice(idx, 1);
  return true;
};

module.exports = { save, getAll, getById, remove };
