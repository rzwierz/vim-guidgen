command! -range NullGuidGen call NullGuidGen(<line1>, <line2>)
command! -range CommonGuidGen call CommonGuidGen(<line1>, <line2>)
command! -range GuidGen call GuidGen(<line1>, <line2>)

let s:DashedGuidRe = '\<\x\{8}-\x\{4}-\x\{4}-\x\{4}-\x\{12}\>'
let s:WppCommaSepGuidRe = '\<\x\{8}, \x\{4}, \x\{4}, \x\{4}, \x\{12}\>'
let s:DefineGuidCommaSepGuidRe = '\<0x\x\{8}, 0x\x\{4}, 0x\x\{4}, 0x\x\{2}, 0x\x\{2}, 0x\x\{2}, 0x\x\{2}, 0x\x\{2}, 0x\x\{2}, 0x\x\{2}, 0x\x\{2}\>'

" Replaces all dashed and comma separated guids in the given range with *the
" same* guid (i.e. all guids in the range will have the same value)
function! InternalGuidGen(FirstLine, LastLine, Guid)
   let DashedGuidReplaced = 1
   let WppCommaSepGuidReplaced = 1
   let DefineGuidCommaSepGuidReplaced = 1

   let Guid = a:Guid
   try
      execute a:FirstLine . "," . a:LastLine . "s/" . s:DashedGuidRe . "/" . Guid . "/g"
   catch
      let DashedGuidReplaced = 0
   endtry

   " Modify the guid to match wpp comma separated definition and replace
   " any wpp comma separated guids found in the range given
   let Guid = a:Guid
   let Guid = substitute(Guid, "-", ", ", "g")
   try
      execute a:FirstLine . "," . a:LastLine . "s/" . s:WppCommaSepGuidRe . "/"  . Guid . "/g"
   catch
      let WppCommaSepGuidReplaced = 0
   endtry

   " Modify the guid to match DEFINE_GUID comma separated definition and replace
   " any DEFINE_GUID comma separated guids found in the range given
   let Guid = a:Guid
   let Guid = substitute(Guid, '^\(\x\{8}\)-\(\x\{4}\)-\(\x\{4}\)', '0x\1, 0x\2, 0x\3, ', "g")
   let Guid = substitute(Guid, '-\(\x\{2}\)\(\x\{2}\)-\(\x\{2}\)\(\x\{2}\)\(\x\{2}\)\(\x\{2}\)\(\x\{2}\)\(\x\{2}\)', '0x\1, 0x\2, 0x\3, 0x\4, 0x\5, 0x\6, 0x\7, 0x\8', "g")
   try
      execute a:FirstLine . "," . a:LastLine . "s/" . s:DefineGuidCommaSepGuidRe . "/"  . Guid . "/g"
   catch
      let DefineGuidCommaSepGuidReplaced = 0
   endtry

   return DashedGuidReplaced || WppCommaSepGuidReplaced || DefineGuidCommaSepGuidReplaced
endfunction

function! NullGuidGen(FirstLine, LastLine)
   if !InternalGuidGen(a:FirstLine, a:LastLine, "00000000-0000-0000-0000-000000000000")
      call EchoError("No GUIDs were found")
   endif
endfunction

function! CommonGuidGen(FirstLine, LastLine)
   if !InternalGuidGen(a:FirstLine, a:LastLine, NewGuid())
      call EchoError("No GUIDs were found")
   endif
endfunction

function! GuidGen(FirstLine, LastLine)
   let SomeGuidsReplaced = 0
   for line in range(a:FirstLine, a:LastLine)
      let SomeGuidsReplaced = InternalGuidGen(line, line, NewGuid()) || SomeGuidsReplaced
   endfor
   if !SomeGuidsReplaced
      call EchoError("No GUIDs were found")
   endif
endfunction

function! EchoError(Message)
   echohl ErrorMsg | echo a:Message | echohl None
endfunction

function! NewGuid()
   return substitute(toupper(system("uuidgen")), "\n", "", "")
endfunction
