;; Constants
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_INACTIVE (err u403))
(define-constant ERR_INSUFFICIENT_FUNDS (err u402))
(define-constant ERR_BLOCK_INFO (err u500))

;; Data vars
(define-data-var asset-counter uint u0)

(define-map data-assets
  uint ;; asset ID
  {
    provider: principal,
    title: (string-ascii 50),
    description: (string-ascii 100),
    price: uint,
    data-uri: (string-ascii 100),
    active: bool
  }
)

(define-map access-log
  { asset-id: uint, user: principal }
  uint) ;; block-height of access

(define-data-var event-counter uint u0)

(define-private (emit-asset-event (event-type (string-ascii 20)) (asset-id uint) (user principal))
    (begin
        (var-set event-counter (+ (var-get event-counter) u1))
        (print { event-type: event-type, 
                 asset-id: asset-id, 
                 user: user, 
                 id: (var-get event-counter) })
        true
    )
)

;; Register new data asset
(define-public (register-asset (title (string-ascii 50)) (desc (string-ascii 100)) (price uint) (uri (string-ascii 100)))
  (let (
    (asset-id (+ u1 (var-get asset-counter)))
    (new-asset {
      provider: tx-sender,
      title: title,
      description: desc,
      price: price,
      data-uri: uri,
      active: true
    })
  )
    (begin
      (map-set data-assets asset-id new-asset)
      (var-set asset-counter asset-id)
      (ok asset-id)
    )
  )
)

;; View data asset
(define-read-only (get-asset (id uint))
  (let ((asset (unwrap! (map-get? data-assets id) (err u404))))
    (ok asset)
  )
)

;; Buy access to a data asset
(define-public (buy-access (id uint))
  (let ((asset (unwrap! (map-get? data-assets id) ERR_NOT_FOUND)))
    (begin
      (asserts! (get active asset) ERR_INACTIVE)
      (asserts! (>= (stx-get-balance tx-sender) (get price asset)) ERR_INSUFFICIENT_FUNDS)

      ;; transfer payment to provider
      (try! (stx-transfer? (get price asset) tx-sender (get provider asset)))

      ;; log access using current block height
      (map-set access-log 
               { asset-id: id, user: tx-sender } 
               burn-block-height)

      ;; emit event
      (emit-asset-event "access-granted" id tx-sender)

      (ok {
        data-uri: (get data-uri asset),
        price: (get price asset)
      })
    )
  )
)

;; Check if user has access
(define-read-only (has-access (id uint) (user principal))
  (is-some (map-get? access-log { asset-id: id, user: user }))
)

;; Disable asset (provider only)
(define-public (disable-asset (id uint))
  (let ((asset (unwrap! (map-get? data-assets id) (err u404))))
    (begin
      (asserts! (is-eq (get provider asset) tx-sender) (err u401))
      (map-set data-assets 
               id 
               (merge asset { active: false }))
      (ok true)
    )
  )
)
