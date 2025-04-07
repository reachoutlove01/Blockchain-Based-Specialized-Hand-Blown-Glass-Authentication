;; Artist Verification Contract
;; Validates legitimate glass artisans

(define-data-var admin principal tx-sender)

;; Map of verified artists
(define-map verified-artists
  { artist-id: (string-utf8 36) }
  {
    name: (string-utf8 100),
    credentials: (string-utf8 500),
    verified: bool,
    verification-date: uint
  }
)

;; Register a new artist (admin only)
(define-public (register-artist (artist-id (string-utf8 36)) (name (string-utf8 100)) (credentials (string-utf8 500)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-none (map-get? verified-artists { artist-id: artist-id })) (err u100))
    (ok (map-set verified-artists
      { artist-id: artist-id }
      {
        name: name,
        credentials: credentials,
        verified: true,
        verification-date: block-height
      }
    ))
  )
)

;; Check if an artist is verified
(define-read-only (is-artist-verified (artist-id (string-utf8 36)))
  (match (map-get? verified-artists { artist-id: artist-id })
    entry (ok (get verified entry))
    (err u404)
  )
)

;; Get artist details
(define-read-only (get-artist-details (artist-id (string-utf8 36)))
  (map-get? verified-artists { artist-id: artist-id })
)

;; Update artist credentials (admin only)
(define-public (update-artist-credentials (artist-id (string-utf8 36)) (credentials (string-utf8 500)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (match (map-get? verified-artists { artist-id: artist-id })
      entry (ok (map-set verified-artists
        { artist-id: artist-id }
        (merge entry { credentials: credentials, verification-date: block-height })
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
