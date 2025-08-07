(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-authorized (err u101))
(define-constant err-insufficient-balance (err u102))
(define-constant err-invalid-amount (err u103))
(define-constant err-factory-not-registered (err u104))
(define-constant err-credit-not-found (err u105))
(define-constant err-already-verified (err u106))
(define-constant err-not-verified (err u107))
(define-constant err-factory-already-registered (err u108))
(define-constant err-verifier-already-registered (err u109))
(define-constant err-listing-not-found (err u110))
(define-constant err-insufficient-payment (err u111))
(define-constant err-listing-already-exists (err u112))
(define-constant err-cannot-buy-own-listing (err u113))

(define-map factories 
  { factory-address: principal }
  {
    name: (string-ascii 50),
    location: (string-ascii 100),
    registration-block: uint,
    is-active: bool,
    total-credits-issued: uint
  }
)

(define-map carbon-credits
  { credit-id: uint }
  {
    factory: principal,
    amount: uint,
    verification-status: (string-ascii 20),
    issue-block: uint,
    metadata: (string-ascii 200),
    verifier: (optional principal)
  }
)

(define-map credit-balances
  { owner: principal, credit-id: uint }
  { balance: uint }
)


(define-map verifiers
  { verifier-address: principal }
  {
    name: (string-ascii 50),
    certification: (string-ascii 100),
    is-active: bool
  }
)

(define-map marketplace-listings
  { listing-id: uint }
  {
    seller: principal,
    credit-id: uint,
    amount: uint,
    price-per-credit: uint,
    total-price: uint,
    is-active: bool,
    created-at: uint
  }
)

(define-data-var next-credit-id uint u1)
(define-data-var total-credits-supply uint u0)
(define-data-var next-listing-id uint u1)

(define-public (register-factory (name (string-ascii 50)) (location (string-ascii 100)))
  (begin
    (asserts! (is-none (map-get? factories { factory-address: tx-sender })) err-factory-already-registered)
    (map-set factories
      { factory-address: tx-sender }
      {
        name: name,
        location: location,
        registration-block: stacks-block-height,
        is-active: true,
        total-credits-issued: u0
      }
    )
    (ok true)
  )
)

(define-public (register-verifier (verifier-address principal) (name (string-ascii 50)) (certification (string-ascii 100)))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (is-none (map-get? verifiers { verifier-address: verifier-address })) err-verifier-already-registered)
    (map-set verifiers
      { verifier-address: verifier-address }
      {
        name: name,
        certification: certification,
        is-active: true
      }
    )
    (ok true)
  )
)

(define-public (issue-carbon-credit (amount uint) (metadata (string-ascii 200)))
  (let (
    (credit-id (var-get next-credit-id))
    (factory-info (unwrap! (map-get? factories { factory-address: tx-sender }) err-factory-not-registered))
  )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (get is-active factory-info) err-not-authorized)
    
    (map-set carbon-credits
      { credit-id: credit-id }
      {
        factory: tx-sender,
        amount: amount,
        verification-status: "pending",
        issue-block: stacks-block-height,
        metadata: metadata,
        verifier: none
      }
    )
    
    (map-set credit-balances
      { owner: tx-sender, credit-id: credit-id }
      { balance: amount }
    )
    
    (map-set factories
      { factory-address: tx-sender }
      (merge factory-info { total-credits-issued: (+ (get total-credits-issued factory-info) amount) })
    )
    
    (var-set next-credit-id (+ credit-id u1))
    (var-set total-credits-supply (+ (var-get total-credits-supply) amount))
    
    (ok credit-id)
  )
)

(define-public (verify-carbon-credit (credit-id uint))
  (let (
    (credit-info (unwrap! (map-get? carbon-credits { credit-id: credit-id }) err-credit-not-found))
    (verifier-info (unwrap! (map-get? verifiers { verifier-address: tx-sender }) err-not-authorized))
  )
    (asserts! (get is-active verifier-info) err-not-authorized)
    (asserts! (is-eq (get verification-status credit-info) "pending") err-already-verified)
    
    (map-set carbon-credits
      { credit-id: credit-id }
      (merge credit-info {
        verification-status: "verified",
        verifier: (some tx-sender)
      })
    )
    
    (ok true)
  )
)

(define-public (reject-carbon-credit (credit-id uint))
  (let (
    (credit-info (unwrap! (map-get? carbon-credits { credit-id: credit-id }) err-credit-not-found))
    (verifier-info (unwrap! (map-get? verifiers { verifier-address: tx-sender }) err-not-authorized))
  )
    (asserts! (get is-active verifier-info) err-not-authorized)
    (asserts! (is-eq (get verification-status credit-info) "pending") err-already-verified)
    
    (map-set carbon-credits
      { credit-id: credit-id }
      (merge credit-info {
        verification-status: "rejected",
        verifier: (some tx-sender)
      })
    )
    
    (ok true)
  )
)

(define-public (transfer-carbon-credit (credit-id uint) (amount uint) (recipient principal))
  (let (
    (credit-info (unwrap! (map-get? carbon-credits { credit-id: credit-id }) err-credit-not-found))
    (sender-balance (default-to u0 (get balance (map-get? credit-balances { owner: tx-sender, credit-id: credit-id }))))
    (recipient-balance (default-to u0 (get balance (map-get? credit-balances { owner: recipient, credit-id: credit-id }))))
  )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (>= sender-balance amount) err-insufficient-balance)
    (asserts! (is-eq (get verification-status credit-info) "verified") err-not-verified)
    
    (map-set credit-balances
      { owner: tx-sender, credit-id: credit-id }
      { balance: (- sender-balance amount) }
    )
    
    (map-set credit-balances
      { owner: recipient, credit-id: credit-id }
      { balance: (+ recipient-balance amount) }
    )
    
    (ok true)
  )
)

(define-public (retire-carbon-credit (credit-id uint) (amount uint))
  (let (
    (credit-info (unwrap! (map-get? carbon-credits { credit-id: credit-id }) err-credit-not-found))
    (user-balance (default-to u0 (get balance (map-get? credit-balances { owner: tx-sender, credit-id: credit-id }))))
  )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (>= user-balance amount) err-insufficient-balance)
    (asserts! (is-eq (get verification-status credit-info) "verified") err-not-verified)
    
    (map-set credit-balances
      { owner: tx-sender, credit-id: credit-id }
      { balance: (- user-balance amount) }
    )
    
    (var-set total-credits-supply (- (var-get total-credits-supply) amount))
    
    (ok true)
  )
)

(define-read-only (get-factory-info (factory-address principal))
  (map-get? factories { factory-address: factory-address })
)

(define-read-only (get-carbon-credit-info (credit-id uint))
  (map-get? carbon-credits { credit-id: credit-id })
)

(define-read-only (get-credit-balance (owner principal) (credit-id uint))
  (default-to u0 (get balance (map-get? credit-balances { owner: owner, credit-id: credit-id })))
)

(define-read-only (get-verifier-info (verifier-address principal))
  (map-get? verifiers { verifier-address: verifier-address })
)

(define-read-only (get-total-credits-supply)
  (var-get total-credits-supply)
)

(define-read-only (get-next-credit-id)
  (var-get next-credit-id)
)

(define-public (deactivate-factory (factory-address principal))
  (let (
    (factory-info (unwrap! (map-get? factories { factory-address: factory-address }) err-factory-not-registered))
  )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set factories
      { factory-address: factory-address }
      (merge factory-info { is-active: false })
    )
    (ok true)
  )
)

(define-public (deactivate-verifier (verifier-address principal))
  (let (
    (verifier-info (unwrap! (map-get? verifiers { verifier-address: verifier-address }) err-not-authorized))
  )
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (map-set verifiers
      { verifier-address: verifier-address }
      (merge verifier-info { is-active: false })
    )
    (ok true)
  )
)

(define-public (create-marketplace-listing (credit-id uint) (amount uint) (price-per-credit uint))
  (let (
    (listing-id (var-get next-listing-id))
    (credit-info (unwrap! (map-get? carbon-credits { credit-id: credit-id }) err-credit-not-found))
    (seller-balance (default-to u0 (get balance (map-get? credit-balances { owner: tx-sender, credit-id: credit-id }))))
    (total-price (* amount price-per-credit))
  )
    (asserts! (> amount u0) err-invalid-amount)
    (asserts! (> price-per-credit u0) err-invalid-amount)
    (asserts! (>= seller-balance amount) err-insufficient-balance)
    (asserts! (is-eq (get verification-status credit-info) "verified") err-not-verified)
    
    (map-set marketplace-listings
      { listing-id: listing-id }
      {
        seller: tx-sender,
        credit-id: credit-id,
        amount: amount,
        price-per-credit: price-per-credit,
        total-price: total-price,
        is-active: true,
        created-at: stacks-block-height
      }
    )
    
    (var-set next-listing-id (+ listing-id u1))
    (ok listing-id)
  )
)

(define-public (buy-marketplace-listing (listing-id uint))
  (let (
    (listing-info (unwrap! (map-get? marketplace-listings { listing-id: listing-id }) err-listing-not-found))
    (seller (get seller listing-info))
    (credit-id (get credit-id listing-info))
    (amount (get amount listing-info))
    (total-price (get total-price listing-info))
    (seller-balance (default-to u0 (get balance (map-get? credit-balances { owner: seller, credit-id: credit-id }))))
    (buyer-balance (default-to u0 (get balance (map-get? credit-balances { owner: tx-sender, credit-id: credit-id }))))
  )
    (asserts! (get is-active listing-info) err-listing-not-found)
    (asserts! (not (is-eq tx-sender seller)) err-cannot-buy-own-listing)
    (asserts! (>= seller-balance amount) err-insufficient-balance)
    
    (try! (stx-transfer? total-price tx-sender seller))
    
    (map-set credit-balances
      { owner: seller, credit-id: credit-id }
      { balance: (- seller-balance amount) }
    )
    
    (map-set credit-balances
      { owner: tx-sender, credit-id: credit-id }
      { balance: (+ buyer-balance amount) }
    )
    
    (map-set marketplace-listings
      { listing-id: listing-id }
      (merge listing-info { is-active: false })
    )
    
    (ok true)
  )
)

(define-public (cancel-marketplace-listing (listing-id uint))
  (let (
    (listing-info (unwrap! (map-get? marketplace-listings { listing-id: listing-id }) err-listing-not-found))
  )
    (asserts! (get is-active listing-info) err-listing-not-found)
    (asserts! (is-eq tx-sender (get seller listing-info)) err-not-authorized)
    
    (map-set marketplace-listings
      { listing-id: listing-id }
      (merge listing-info { is-active: false })
    )
    
    (ok true)
  )
)

(define-read-only (get-marketplace-listing (listing-id uint))
  (map-get? marketplace-listings { listing-id: listing-id })
)

(define-read-only (get-next-listing-id)
  (var-get next-listing-id)
)