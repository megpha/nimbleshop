# nimbleshop_authorizedotnet extension

This is stripe extension for [nimbleShop](http://www.nimbleShop.org) .

# Dependencies

This gem relies on a model called `PaymentMethod` and this model should
have a column called `metadata` of type `text`. Given below is an
example that would work

```
class CreatePaymentMethods < ActiveRecord::Migration
  def change
    create_table :payment_methods do |t|
      t.string  :name
      t.text    :description
      t.string  :type
      t.string  :permalink, null: false
      t.text    :metadata

      t.timestamps
    end
    add_index :payment_methods, :permalink, unique: true
  end
end
```


# Documentation

Documentation is available at [http://nimbleshop.org/authorizedotnet.html](http://nimbleshop.org/authorizedotnet.html) .

# License

This gem uses [MIT license](http://www.opensource.org/licenses/mit-license.php) .
