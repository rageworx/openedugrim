(define *lua-keywords*
 "assert|loadstring|file|io|string|math|coroutine|userdata|dofile")

(define *lua-typewords*
 "boolean|number|table|local|global|function|for|do|end|return|if|then|else|or|and|")
  
(define-mode lua-mode
  "Mode for editing LUA script."
  (syn 'default #f 'default-face)
  (syn 'regex (string-append "\\<(" *lua-keywords* ")\\>") 'keyword-face)
  (syn 'regex (string-append "\\<(" *lua-typewords* ")\\>") 'type-face)
  (syn 'regex "^\\s*#\\s*\\w+" 'preprocessor-face)
  (syn 'regex "^\\s*#\\s*<?.*>" 'preprocessor-face)
  (syn 'exact "nil" 'keyword-face)
  ;; match strings and single characters, including escape sequences
  (syn 'regex "\"([^\"]|\\\\\"|\\\\)*\"" 'string-face)
  (syn 'regex "'(.|\\\\\')'" 'string-face)
  (syn 'eol  "--" 'comment-face)
  (syn 'block '("--[[" . "]]--") 'comment-face)
  (syn 'regex "(FIXME|TODO|XXX):" 'warning-face))
