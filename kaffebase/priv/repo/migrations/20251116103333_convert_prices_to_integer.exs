defmodule Kaffebase.Repo.Migrations.ConvertPricesToInteger do
  use Ecto.Migration

  def up do
    # Convert item.price_nok from decimal to integer
    execute """
    ALTER TABLE item RENAME COLUMN price_nok TO price_nok_old;
    """

    execute """
    ALTER TABLE item ADD COLUMN price_nok INTEGER NOT NULL DEFAULT 0;
    """

    execute """
    UPDATE item SET price_nok = CAST(ROUND(price_nok_old) AS INTEGER);
    """

    execute """
    ALTER TABLE item DROP COLUMN price_nok_old;
    """

    # Convert customization_value.price_increment_nok from decimal to integer
    execute """
    ALTER TABLE customization_value RENAME COLUMN price_increment_nok TO price_increment_nok_old;
    """

    execute """
    ALTER TABLE customization_value ADD COLUMN price_increment_nok INTEGER NOT NULL DEFAULT 0;
    """

    execute """
    UPDATE customization_value SET price_increment_nok = CAST(ROUND(price_increment_nok_old) AS INTEGER);
    """

    execute """
    ALTER TABLE customization_value DROP COLUMN price_increment_nok_old;
    """
  end

  def down do
    # Reverse: integer back to decimal
    execute """
    ALTER TABLE item RENAME COLUMN price_nok TO price_nok_old;
    """

    execute """
    ALTER TABLE item ADD COLUMN price_nok REAL NOT NULL DEFAULT 0;
    """

    execute """
    UPDATE item SET price_nok = CAST(price_nok_old AS REAL);
    """

    execute """
    ALTER TABLE item DROP COLUMN price_nok_old;
    """

    execute """
    ALTER TABLE customization_value RENAME COLUMN price_increment_nok TO price_increment_nok_old;
    """

    execute """
    ALTER TABLE customization_value ADD COLUMN price_increment_nok REAL NOT NULL DEFAULT 0;
    """

    execute """
    UPDATE customization_value SET price_increment_nok = CAST(price_increment_nok_old AS REAL);
    """

    execute """
    ALTER TABLE customization_value DROP COLUMN price_increment_nok_old;
    """
  end
end
