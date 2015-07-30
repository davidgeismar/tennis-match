module MangoPayments
  class CreatePayoutService
    def initialize(tournament, subscriptions)
      @tournament     = tournament
      @subscriptions  = subscriptions
    end

    def call
      amount        = @tournament.amount * @subscriptions.count
      amount_cents  = amount * 100
      fees_cents    = ((amount * 0.1) * 100).to_i
      transfer      = @tournament.transfers.create(status: 'pending', category: 'payout')

      transaction   = MangoPay::PayOut::BankWire.create(
        AuthorId:         tournament.mangopay_user_id,
        DebitedWalletId:  tournament.mangopay_wallet_id,
        DebitedFunds:     { Currency: 'EUR', Amount: amount_cents }, # TODO: change this.
        Fees:             { Currency: 'EUR', Amount: fees_cents },   # TODO: change this.
        BankAccountId:    tournament.mangopay_bank_account_id,
        BankWireRef:      'Virement WeTennis',
      )

      transfer.update(
        archive:                  transaction,
        mangopay_transaction_id:  transaction['Id'],
        status:                   (transaction['Status'] == 'SUCCEEDED' ? 'success' : 'failed')
      )

      if transfer.status == 'success'
        @tournament.update(funds_received: true)
      else
        false
      end
    end
  end
end
