/// <reference path="../pb_data/types.d.ts" />
migrate(
  (app) => {
    const collection = app.findCollectionByNameOrId("pbc_608092820");

    // add field
    collection.fields.addAt(
      4,
      new Field({
        cascadeDelete: false,
        collectionId: "pbc_2603350950",
        hidden: false,
        id: "relation4098952250",
        maxSelect: 1,
        minSelect: 0,
        name: "default_value",
        presentable: false,
        required: false,
        system: false,
        type: "relation"
      })
    );

    // add field
    collection.fields.addAt(
      5,
      new Field({
        hidden: false,
        id: "bool3998393131",
        name: "multiple_choice",
        presentable: false,
        required: false,
        system: false,
        type: "bool"
      })
    );

    return app.save(collection);
  },
  (app) => {
    const collection = app.findCollectionByNameOrId("pbc_608092820");

    // remove field
    collection.fields.removeById("relation4098952250");

    // remove field
    collection.fields.removeById("bool3998393131");

    return app.save(collection);
  }
);
