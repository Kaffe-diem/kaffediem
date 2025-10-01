migrate((app) => {
    let superusers = app.findCollectionByNameOrId("_superusers")
    let users = app.findCollectionByNameOrId("user")

    if (process.env.POCKETBASE_ENVIRONMENT == "dev") {
      let superuser = new Record(superusers)
      let user = new Record(users)

      superuser.set("email", process.env.PB_TEST_ADMIN_EMAIL)
      user.set("email", process.env.PB_TEST_ADMIN_EMAIL)
      superuser.set("password", process.env.PB_TEST_ADMIN_PASSWORD)
      user.set("password", process.env.PB_TEST_ADMIN_PASSWORD)

      user.set("is_admin", true)
      user.set("verified", true)

      app.save(superuser)
      app.save(user)
    }
}, (app) => {
    try {
        let superuser = app.findAuthRecordByEmail("_superusers", process.env.PB_TEST_ADMIN_EMAIL)
        let user = app.findAuthRecordByEmail("user", process.env.PB_TEST_ADMIN_EMAIL)
        app.delete(superuser)
        app.delete(user)
    } catch {
    }
})
