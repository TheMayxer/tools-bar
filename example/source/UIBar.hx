package;

import flixel.FlxState;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.FlxSprite;
import flixel.math.FlxMath;

typedef TextProperties = {
    var font:String;
    var textColor:FlxColor;
    var textSize:Int;
    var borderColor:FlxColor;
};

typedef Informations = {
	var text:String;
	var onClick:Array<Dynamic>;
	var namesList:Array<String>;
};

class UIBar extends FlxGroup
{
    var back:FlxSprite;
    var optionsBack:FlxSprite;
    var listGroup:FlxTypedGroup<FlxText>;
    var optionsGroup:FlxTypedGroup<FlxText>;

    var informations:Array<Informations> = [];

    var objIndex:Int = null;
    var isAnimated:Bool = true;
    var newOptionsBackX:Float = 0;

    var textProperties:TextProperties;

    public function new(list:Array<Informations>, ?color:FlxColor = FlxColor.BLUE) {
        super();

        this.informations = list;

        setProperties();

        back = new FlxSprite();
        back.makeGraphic(FlxG.width, 30, color);
        add(back);

        listGroup = new FlxTypedGroup<FlxText>();
        add(listGroup);

        optionsBack = new FlxSprite(0,back.y+back.height);
        optionsBack.makeGraphic(1,1,color);
        optionsBack.visible = false;
        add(optionsBack);

        optionsGroup = new FlxTypedGroup<FlxText>();
        add(optionsGroup);

        for(i in 0...this.informations.length) {
            var tab = new FlxText(0,0,0,informations[i].text,20);
            setTextProperty(tab);
            tab.y = back.y+back.height/2-tab.height/2;
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

        for(i => text in listGroup.members) {
            if(FlxG.mouse.overlaps(text)&&FlxG.mouse.justPressed) regenerateOptions(text);

            var lastText = listGroup.members[i-1];
            text.x = lastText!=null ?(isAnimated? FlxMath.lerp(text.x, lastText.x + lastText.width + 5, elapsed*10) : lastText.x + lastText.width + 5) : 5;
            text.y = isAnimated? FlxMath.lerp(text.y, back.y+back.height/2-text.height/2, elapsed*8) : back.y+back.height/2-text.height/2;
        }

        optionsBack.x = isAnimated ? FlxMath.lerp(optionsBack.x, newOptionsBackX, elapsed*14) : newOptionsBackX;

        optionsGroup.forEachExists(function(text:FlxText){
            text.x = optionsBack.x+5;
        });
            
        
    }

    public function setProperties(?font:String = 'vcr.ttf', ?textSize:Int = 20, ?textColor:FlxColor = FlxColor.WHITE, ?borderColor:FlxColor = FlxColor.BLACK) {
        textProperties = {
            font: font,
            textColor: textColor,
            textSize: textSize,
            borderColor: borderColor,
        };

        if(optionsGroup!=null&&listGroup!=null) {
            for(group in [optionsGroup, listGroup]) group.forEachExists((text:FlxText)->setTextProperty(text));
        }
    }

    public function addOption(newList:Informations) {
        this.informations.push(newList);

        var newTab = new FlxText(listGroup.members[listGroup.length-1].x + listGroup.members[listGroup.length-1].width+5,back.y+back.height/2-textProperties.textSize/2,0,newList.text,20);
        setTextProperty(newTab);
        newTab.ID = listGroup.length;
        listGroup.add(newTab);
    }

    public function removeOption(index:Int) {
        if(listGroup.members[index]!=null) {
            this.informations.remove(informations[index]);
            listGroup.remove(listGroup.members[index], true);
        }

        for(i in 0...informations.length) for(text in listGroup.members) text.ID = i;
    }

    public function setTextProperty(text:FlxText) {
        text.setFormat('assets/fonts/'+textProperties.font, textProperties.textSize, textProperties.textColor, LEFT, OUTLINE, textProperties.borderColor);
        text.setBorderStyle(OUTLINE, textProperties.borderColor, 1,1);
        text.updateHitbox();
    }


    function regenerateOptions(obj:FlxText) {

        objIndex = obj.ID;
        newOptionsBackX = obj.x;

        optionsGroup.forEachExists(function(text:FlxText){optionsGroup.remove(text);});

        var biggestWidthMember:Array<Float> = [];

        for(i in 0...this.informations[objIndex].namesList.length) {
            var newText = new FlxText(optionsBack.x+5,(back.y+back.height)+5,0,this.informations[objIndex].namesList[i],20);
            setTextProperty(newText);
            newText.ID = i;
            optionsGroup.add(newText);

            if(optionsGroup.members[i-1]!=null) newText.y = optionsGroup.members[i-1].y+optionsGroup.members[i-1].height+5;

            biggestWidthMember.push(newText.width);

            if(biggestWidthMember[i] > biggestWidthMember[0]) biggestWidthMember[0] = biggestWidthMember[i]; //https://community.haxe.org/t/trying-to-implement-array-min/4013
        }

        optionsBack.visible = true;
        optionsBack.setGraphicSize(Std.int(biggestWidthMember[0])+5,(obj.height*informations[objIndex].namesList.length)+20);
        optionsBack.updateHitbox();

    }
}