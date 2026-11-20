package balphabet;

import funkin.util.FileUtil;
import funkin.util.FileWriteMode;
using StringTools;

class BAZipUtil
{
    final EXCLUDED_FILES:Array<String> =
    [
        '.gitattributes',
        '.gitignore',
        'astc-data.json',
        'ZipUtil.hx'
    ];

    final EXCLUDED_FOLDERS:Array<String> =
    [
        '.git',
        'astc-images',
        'fla',
        'shared',
        'export',
        'cppia-scr'
    ];

    final EXCLUDED_FILE_EXT:Array<String> =
    [
        '.zip',
        '.fnfmod'
    ];

    final PATH:String = 'mods/BetterAlphabet/';

    var ASTC_EXCLUDES:Array<String> = [];
    var exportToMobile:Bool = false;
    var zipEntries:Array<Entry> = [];

    public function new(mobile:Bool = false):Void
    {
        exportToMobile = mobile;

        ASTC_EXCLUDES = FileUtil.readJSONFromPath('$PATH/astc-data.json').excludes;
    }

    public function packageMod():Void
    {
        final exportPath:String = '$PATH/export/betteralphabet-3_0_0${(exportToMobile ? '-mobile' : '')}.fnfmod';
        makeEntries(PATH);
        for (entry in zipEntries)
        {
            trace(entry.fileName);
        }
        FileUtil.saveFilesAsZIPToPath(zipEntries, exportPath, FileWriteMode.Force);
    }

    function makeEntries(path:String):Void
    {
        final pathItems:Array<String> = readDirectory(path);
        for (item in pathItems)
        {
            if (!FileUtil.directoryExists(path + item))
            {
                trace(path + item);

                var pathToUse:String = path;
                var itemToUse:String = item;

                if (exportToMobile && pathToUse.contains('images/') && itemToUse.endsWith('.png') && !containsAny(pathToUse.replace(PATH, '') + itemToUse, ASTC_EXCLUDES))
                {
                    pathToUse = pathToUse.replace('images/', 'astc-images/images/');
                    itemToUse = itemToUse.replace('.png', '.astc');
                }

                var bytes:Bytes = FileUtil.readBytesFromPath(pathToUse + itemToUse);
                pathToUse.replace('astc-images/', '');
                zipEntries.push(FileUtil.makeZIPEntryFromBytes(path.replace(PATH, '') + itemToUse, bytes));
            }
            else
            {
                makeEntries(path + item + '/');
            }
        }
    }

    /**
     * Reads a directory and automatically filters out excluded files and such.
     */
    function readDirectory(path:String):Array<String>
    {
        var entries:Array<String> = FileUtil.readDir(path);
        return entries.filter(function(entry:String):Bool
        {
            return !EXCLUDED_FILES.contains(entry) && !containsAny(entry, EXCLUDED_FOLDERS) && !containsAny(entry, EXCLUDED_FILE_EXT);
        });
    }

    /**
     * Check to see if a path contains any of the elements of a given array.
     */
    function containsAny(path:String, elements:Array<String>):Bool
    {
        if (path.endsWith('.png') && (ASTC_EXCLUDES == null || ASTC_EXCLUDES.length == 0)) return false;
        var containsElement:Bool = false;
        for (element in elements)
        {
            if (path.contains(element))
            {
                containsElement = true;
                break;
            }
        }
        return containsElement;
    }
}