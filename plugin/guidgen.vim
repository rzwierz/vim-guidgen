command! -range GuidGen call GuidGen(<line1>, <line2>)
command! -range CommonGuidGen call CommonGuidGen(<line1>, <line2>)

let s:DashedGuidRe = "\\<\\x\\{8}-\\x\\{4}-\\x\\{4}-\\x\\{4}-\\x\\{12}\\>"
let s:CommaSepGuidRe = "\\<\\x\\{8}, \\x\\{4}, \\x\\{4}, \\x\\{4}, \\x\\{12}\\>"

" Replaces all dashed and comma separated guids in the given range with *the
" same* guid (i.e. all guids in the range will have the same value)
function! InternalGuidGen(FirstLine, LastLine)
   let DashedGuidReplaced = 1
   let CommaSepGuidReplaced = 1

   " Generate new guid and use it to replace any dashed guids found in the
   " range given
   let Guid = substitute(toupper(system("uuidgen.exe")), "\r\n", "", "")
   try
      execute a:FirstLine . "," . a:LastLine . "s/" . s:DashedGuidRe . "/" . Guid . "/g"
   catch
      let DashedGuidReplaced = 0
   endtry

   " Modify the previously generated guid to be comma separated and replace
   " any comma separated guids found in the range given
   let Guid = substitute(Guid, "-", ", ", "g")
   try
      execute a:FirstLine . "," . a:LastLine . "s/" . s:CommaSepGuidRe . "/"  . Guid . "/g"
   catch
      let CommaSepGuidReplaced = 0
   endtry

   return DashedGuidReplaced || CommaSepGuidReplaced
endfunction

function! CommonGuidGen(FirstLine, LastLine)
   if !InternalGuidGen(a:FirstLine, a:LastLine)
      call EchoError("No GUIDs were found")
   endif
endfunction

function! GuidGen(FirstLine, LastLine)
   let SomeGuidsReplaced = 0
   for line in range(a:FirstLine, a:LastLine)
      let SomeGuidsReplaced = InternalGuidGen(line, line) || SomeGuidsReplaced
   endfor
   if !SomeGuidsReplaced
      call EchoError("No GUIDs were found")
   endif
endfunction

function! EchoError(Message)
   echohl ErrorMsg | echo a:Message | echohl None
endfunction
