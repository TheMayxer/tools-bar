package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.FlxSprite;

typedef TextProperties = {
    var font:String;
    var textColor:FlxColor;
    var textSize:Int;
    var border:Bool;
    var borderColor:FlxColor;
};

class UIBar extends FlxGroup
{
    var back:FlxSprite;
    var optionsBack:FlxSprite;
    var informations:Array<Dynamic> = [];
    var listGroup:FlxTypedGroup<FlxText>;
    var optionsGroup:FlxTypedGroup<FlxText>;
    var objIndex = null;

    var textProperties:TextProperties;

    public function new(list:Array<Dynamic>, ?border:Bool = false, font:String, color:FlxColor,?textSize:Float = 20,?textColor:FlxColor = FlxColor.WHITE, ?borderColor:FlxColor  = FlxColor.BLACK) {
        super();

        this.informations = list;

        this.textProperties = {
            font: font,
            textSize: Std.int(textSize),
            textColor: textColor,
            border: border,
            borderColor: borderColor
        };


        back = new FlxSprite();
        back.makeGraphic(FlxG.width, 30, color);
        add(back);

        listGroup = new FlxTypedGroup<FlxText>();
        add(listGroup);

        optionsBack = new FlxSprite();
        optionsBack.makeGraphic(1,1,color);
        optionsBack.visible = false;
        add(optionsBack);

        optionsGroup = new FlxTypedGroup<FlxText>();
        add(optionsGroup);

        for(i in 0...this.informations.length) {
            var tab = new FlxText(0,0,0,informations[i].text,textProperties.textSize);
            tab.font = textProperties.font;
            tab.y = back.y+back.height/2-tab.height/2;
            if(textProperties.border == true) tab.setFormat(textProperties.font, textProperties.textSize, textProperties.textColor, LEFT, OUTLINE, textProperties.borderColor);
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
                        if(FlxG.mouse.overlaps(obj)) this.informations[objIndex].onClick[obj.ID]();
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
            var newText = new FlxText(obj.x+5,(back.y+back.height)+5,0,this.informations[objIndex].namesList[i],textProperties.textSize);
            newText.font = textProperties.font;
            newText.ID = i;
            if(textProperties.border == true) newText.setFormat(textProperties.font, textProperties.textSize, textProperties.textColor, LEFT, OUTLINE, textProperties.borderColor);
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