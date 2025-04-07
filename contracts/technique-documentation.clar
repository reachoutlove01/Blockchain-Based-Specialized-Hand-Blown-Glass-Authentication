;; Technique Documentation Contract
;; Records specific glassblowing methods

(define-data-var admin principal tx-sender)

;; Map of documented techniques
(define-map techniques
  { technique-id: (string-utf8 36) }
  {
    name: (string-utf8 100),
    description: (string-utf8 1000),
    difficulty: uint,
    origin: (string-utf8 100),
    documented-by: principal,
    documentation-date: uint
  }
)

;; Document a new technique (admin only)
(define-public (document-technique
    (technique-id (string-utf8 36))
    (name (string-utf8 100))
    (description (string-utf8 1000))
    (difficulty uint)
    (origin (string-utf8 100)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-none (map-get? techniques { technique-id: technique-id })) (err u100))
    (ok (map-set techniques
      { technique-id: technique-id }
      {
        name: name,
        description: description,
        difficulty: difficulty,
        origin: origin,
        documented-by: tx-sender,
        documentation-date: block-height
      }
    ))
  )
)

;; Get technique details
(define-read-only (get-technique (technique-id (string-utf8 36)))
  (map-get? techniques { technique-id: technique-id })
)

;; Update technique description (admin only)
(define-public (update-technique
    (technique-id (string-utf8 36))
    (description (string-utf8 1000))
    (difficulty uint))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (match (map-get? techniques { technique-id: technique-id })
      entry (ok (map-set techniques
        { technique-id: technique-id }
        (merge entry {
          description: description,
          difficulty: difficulty,
          documentation-date: block-height
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
