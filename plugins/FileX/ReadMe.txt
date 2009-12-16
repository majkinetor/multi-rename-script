-------------------------------------------------------------------------------
   FileX 1.6
-------------------------------------------------------------------------------
FileX is the TC content plugin for display various information about files.
Plugin provides also some useful fields for search and filtering.

-------------------------------------------------------------------------------
  Changes History
-------------------------------------------------------------------------------
Version 1.7
- Added ContentType(MIME) field.

Version 1.6
- Added field for file extents number
- Added 3 fields for upper level directory names (parent,grandpa,greatgrandpa)
- Added 2 fields for UNC names (server & share)

Version 1.5
- Fixed bug in owner info for network drives and UNC names
- Fixed wrong(old) directory name in pluginst.inf file.
-------------------------------------------------------------------------------

Fields list
- registered file type
- associated program 
- depth level relative to disk/share root
- owner name
- owner domain
- owner type
- drive type.
- FullPathLen
- FileNameLen
- PathLen
- ExtLen
- Group
- GroupN
- EmptyDir
- ZeroSizeDir
- Extents
- ParentDir
- GrandPaDir
- GtGrandPaDir
- ShareName 
- ServerName 

Groups are defined in FileX.ini in the section [Group].
Every group defined like

GroupName=str1:str2:str3

Extended conditions.
--------------------
strX can be string prefixed by ?, * or | char.
It allows define aditional conditions based on full filename. 
- ? means string MAY be in filename (like extension but anywhere in filename)
- * means string MUST be un filename
- | means string MUST NOT be in filename

Examples: 
Document=doc:pdf:djvu:?book
CDImage=iso:bin:|\MyProjects


-------------------------------------------------------------------------------
Autor: MGP Software Ltd.
Email: support@mgpsoft.com
