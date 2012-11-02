module NimbleshopCod
  class Cod < PaymentMethod
    validates_presence_of :name
  end
end
