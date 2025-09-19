/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("l17x9aj9ghmi5b0")

  // update field
  collection.fields.addAt(2, new Field({
    "hidden": false,
    "id": "xj4ns90n",
    "name": "open",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  // update field
  collection.fields.addAt(3, new Field({
    "hidden": false,
    "id": "bool2058414169",
    "name": "show_message",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("l17x9aj9ghmi5b0")

  // update field
  collection.fields.addAt(2, new Field({
    "hidden": false,
    "id": "xj4ns90n",
    "name": "online",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  // update field
  collection.fields.addAt(3, new Field({
    "hidden": false,
    "id": "bool2058414169",
    "name": "visible",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "bool"
  }))

  return app.save(collection)
})
