# AutoIt-PDFFolderPrint

Automatically print pdf in folder

I highly recommend using Sumatra PDF, the only one printing then exiting easily.

![AutoIt-PDFFolderPrint](https://user-images.githubusercontent.com/7203617/122071424-02a64780-cdf7-11eb-8d85-f807a695b75b.png)

## PDF Reader

You need to install a PDF Reader with the possibility to print from command line:

- [Acrobat Reader DC](https://get.adobe.com/uk/reader/)
  - `AcroRd32.exe /p <filename>` Open and go straight to the print dialog
- [Foxit Reader](https://www.foxit.com/)
  - `FoxitReader.exe /p <filename>` Print the document with default printer
- [Sumatra PDF](https://www.sumatrapdfreader.org/)
  - `SumatraPDF.exe -print-to-default -exit-when-done <filename>` Prints all files indicated on this command line to the system default printer. After printing, SumatraPDF exits immediately (check the error code for failure).
