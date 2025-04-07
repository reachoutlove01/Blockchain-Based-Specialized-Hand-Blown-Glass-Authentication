;; Studio Verification Contract
;; Confirms creation in recognized workshops

(define-data-var admin principal tx-sender)

;; Map of verified studios
(define-map verified-studios
  { studio-id: (string-utf8 36) }
  {
    name: (string-utf8 100),
    location: (string-utf8 200),
    founding-year: uint,
    specialties: (string-utf8 500),
    verified: bool,
    verification-date: uint
  }
)

;; Register a new studio (admin only)
(define-public (register-studio
    (studio-id (string-utf8 36))
    (name (string-utf8 100))
    (location (string-utf8 200))
    (founding-year uint)
    (specialties (string-utf8 500)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-none (map-get? verified-studios { studio-id: studio-id })) (err u100))
    (ok (map-set verified-studios
      { studio-id: studio-id }
      {
        name: name,
        location: location,
        founding-year: founding-year,
        specialties: specialties,
        verified: true,
        verification-date: block-height
      }
    ))
  )
)

;; Check if a studio is verified
(define-read-only (is-studio-verified (studio-id (string-utf8 36)))
  (match (map-get? verified-studios { studio-id: studio-id })
    entry (ok (get verified entry))
    (err u404)
  )
)

;; Get studio details
(define-read-only (get-studio-details (studio-id (string-utf8 36)))
  (map-get? verified-studios { studio-id: studio-id })
)

;; Update studio information (admin only)
(define-public (update-studio
    (studio-id (string-utf8 36))
    (location (string-utf8 200))
    (specialties (string-utf8 500)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (match (map-get? verified-studios { studio-id: studio-id })
      entry (ok (map-set verified-studios
        { studio-id: studio-id }
        (merge entry {
          location: location,
          specialties: specialties,
          verification-date: block-height
        })
      ))
      (err u404)
    )
  )
)

;; Transfer admin rights
(define-public (transfer-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)
