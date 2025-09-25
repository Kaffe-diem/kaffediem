/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("s6q4j5bzs2tt8yq")

  // add field
  collection.fields.addAt(4, new Field({
    "cascadeDelete": false,
    "collectionId": "pbc_608092820",
    "hidden": false,
    "id": "relation2254785150",
    "maxSelect": 999,
    "minSelect": 0,
    "name": "customization_keys",
    "presentable": false,
    "required": false,
    "system": false,
    "type": "relation"
  }))

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("s6q4j5bzs2tt8yq")

  // remove field
  collection.fields.removeById("relation2254785150")

  return app.save(collection)
})
