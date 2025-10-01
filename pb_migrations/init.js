migrate(
  (app) => {
    let superusers = app.findCollectionByNameOrId("_superusers");
    let users = app.findCollectionByNameOrId("user");

    if (process.env.POCKETBASE_ENVIRONMENT == "dev") {
      const createRecord = (collection, data) => {
        const record = new Record(collection);
        Object.entries(data).forEach(([key, value]) => record.set(key, value));
        app.save(record);
      };

      const password = process.env.PB_TEST_PASSWORD;

      createRecord(superusers, {
        email: process.env.PB_TEST_ADMIN_EMAIL,
        password
      });

      createRecord(users, {
        email: process.env.PB_TEST_USER_EMAIL,
        password,
        verified: true,
        is_admin: false
      });

      createRecord(users, {
        email: process.env.PB_TEST_ADMIN_EMAIL,
        password,
        verified: true,
        is_admin: true
      });
    }
  },
  (app) => {
    const safeDelete = (collection, email) => {
      try {
        const record = app.findAuthRecordByEmail(collection, email);
        if (record) app.delete(record);
      } catch {}
    };

    safeDelete("_superusers", process.env.PB_TEST_ADMIN_EMAIL);
    safeDelete("user", process.env.PB_TEST_USER_EMAIL);
    safeDelete("user", process.env.PB_TEST_ADMIN_EMAIL);
  }
);
