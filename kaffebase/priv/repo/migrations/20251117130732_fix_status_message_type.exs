defmodule Kaffebase.Repo.Migrations.FixStatusMessageType do
  use Ecto.Migration

  def up do
    execute """
    ALTER TABLE status DROP COLUMN message;
    """

    execute """
    ALTER TABLE status ADD COLUMN message_id INTEGER;
    """
  end

  def down do
    execute """
    ALTER TABLE status DROP COLUMN message_id;
    """

    execute """
    ALTER TABLE status ADD COLUMN message TEXT;
    """
  end
end
