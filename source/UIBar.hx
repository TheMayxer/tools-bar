package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.FlxSprite;

class UIBar extends FlxGroup
{
    var back:FlxSprite;
    var optionsBack:FlxSprite;
    var informations:Array<Dynamic> = [];
    var listGroup:FlxTypedGroup<FlxText>;
    var optionsGroup:FlxTypedGroup<FlxText>;
    var objIndex = null;
    var font = 'assets/fonts/vcr.ttf';

    public function new(list:Array<Dynamic>) {
        super();

        this.informations = list;

        back = new FlxSprite();
        back.makeGraphic(FlxG.width, 30, FlxColor.BLUE);
        add(back);

        listGroup = new FlxTypedGroup<FlxText>();
        add(listGroup);

        optionsBack = new FlxSprite();
        optionsBack.makeGraphic(1,1,FlxColor.BLUE);
        optionsBack.visible = false;
        add(optionsBack);

        optionsGroup = new FlxTypedGroup<FlxText>();
        add(optionsGroup);

        for(i in 0...this.informations.length) {
            var tab = new FlxText(0,0,0,informations[i].text,20);
            tab.font = font;
            tab.y = back.y+back.height/2-t.height/2;
            tab.ID = i;
            listGroup.add(tab);

            if(listGroup.members[i-1]!=null) tab.x = (listGroup.members[i-1].x + listGroup.members[i-1].width + 10);
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(optionsBack.visible) {
            if(FlxG.mouse.justPressed) {
                if(FlxG.mouse.overlaps(optionsBack)) {
                    optionsGroup.forEachExists(function(obj:FlxText){
                        if(FlxG.mouse.overlaps(obj)&&FlxG.mouse.justPressed) this.informations[objIndex].onClick[obj.ID]();
                    });
                } else {
                    optionsBack.visible = false;
                    optionsGroup.forEachExists(function(obj:FlxText){optionsGroup.remove(obj);});
                }
            }
        }

        for(mem in listGroup.members) 
            if(FlxG.mouse.overlaps(mem)&&FlxG.mouse.justPressed) regenerateOptions(mem);
        
    }

    function regenerateOptions(obj:FlxText) {

        objIndex = obj.ID;

        optionsGroup.forEachExists(function(text:FlxText){optionsGroup.remove(text);});

        var biggestWidthMember:Array<Float> = [];

        for(i in 0...this.informations[objIndex].namesList.length) {
            var newText = new FlxText(obj.x+5,(back.y+back.height)+5,0,this.informations[objIndex].namesList[i],20);
            newText.font = font;
            newText.ID = i;
            optionsGroup.add(newText);

            if(optionsGroup.members[i-1]!=null) newText.y = optionsGroup.members[i-1].y+optionsGroup.members[i-1].height+5;

            biggestWidthMember.push(newText.width);

            if(biggestWidthMember[i] > biggestWidthMember[0]) biggestWidthMember[0] = biggestWidthMember[i]; //https://community.haxe.org/t/trying-to-implement-array-min/4013
        }

        optionsBack.visible = true;
        optionsBack.setGraphicSize(Std.int(biggestWidthMember[0])+5,30*this.informations[objIndex].namesList.length);
        optionsBack.updateHitbox();
        optionsBack.setPosition(obj.x,back.y+back.height);

    }
}