/*
===============================================================================
= MOVIECLIP/TEXTFIELD/SOUND TWEENING PROTOTYPE(s)
-------------------------------------------------------------------------------
=
= MC_TWEEN
= Created to be a helpful tweening extension for mortal users
= Find documentation and examples at the site:
= http://hosted.zeh.com.br/mctween/
=
= By Zeh Fernando
= z [AT] zeh.com.br
= 2003-2006
= Sao Paulo, Brazil
= http://www.zeh.com.br
=
-------------------------------------------------------------------------------
=
= This tweens given movieclip properties from their current values to new values,
= during an specified time. It's inspired by Jonas Galvez's simpleTween method
= and created to be *easy* to non-experienced coders (designers).
=
-------------------------------------------------------------------------------
= Version: 2.28.29
= Latest changes:
=        (2003) apr 05 (1.0.0) - first version
=               apr 06 (1.1.0) - added callback property to mc.tween()
=                      (1.1.1) - code fixing/cleaning
=                      (1.2.1) - added mc.isTweening(), mc.getTweens()
=               apr 07 (1.3.1) - added initial delay property to mc.tween()
=               apr 08 (1.3.2) - using onEnterFrame instead of setInterval
=               apr 11 (1.3.3) - added some comments, deleted some old code
=                      (1.4.3) - added some shortcut methods (easier to use)
=               apr 29 (1.5.3) - updated with robert penner's equations v1.4
=               may 02 (1.6.3) - updated with robert penner's equations v1.5
=                      (1.7.3) - added mc.colorTo(), a shortcut/helper method
=               may 06 (1.7.4) - fixed a callback bug on the slideTo method -
=                                props to Gregg Wygonik for pointing that out
=               may 11 (1.8.4) - added mc.stopTween() to stop tweenings
=               may 12 (1.8.5) - fixed a really stupid colorTo() error
=               may 12 (1.9.5) - added mc.colorTransformTo(), a shortcut/helper
=                                method which enables color.setTransform tweens
=               may 13 (1.9.6) - ditched mc.colorTo()'s original code. now it's
=                                based on a mc.colorTransformTo() call
=              jul 23 (1.10.6) - added another shortcut, scaleTo()
=              jul 25 (1.11.6) - added another shortcut, rotateTo() (duh)
=              jul 27 (1.11.7) - made colorTransformTo() better handle
=                                undefined properties and not create unneeded
=                                tween movieclips (faster)
=              aug 26 (1.12.7) - completely revamped the frame control, to use
=                                one submovieClip for each movieclip instead
=                                of a submovieClip for each property (cleaner)
=              oct 01 (1.12.8) - minor fix (mispell) on stopTween() (thanks kim)
=              dec 02 (1.12.9) - fixed minor alphaTo+colorTo+colorTransformTo
=                                issue that broke simultaneous calls
=       (2004) jan 23 (2.12.9) - completely revamped the frame control system
=                                (again): it now uses one single mc at _root
=                                (faster, cleaner)
=                              - callback functionality scope changed. NOT
=                                BACKWARDS COMPATIBLE BY DEFAULT! search for
=                                "backwardCallbackTweening" for help on how
=                                to make it compatible
=              feb 10 (2.13.9) - better time control for synch start
=              feb 10 (2.14.9) - made it possible to tween the same property
=                                several times (not direct overwritting) - ie,
=                                complex animations are now possible with
=                                sequence tweenings
=             feb 11 (2.14.10) - optimizations for speed
=             feb 17 (2.15.10) - added lockTween() and unlockTween()
=             feb 18 (2.15.11) - stoptween() fixed, not updating $_tweenCount
=             mar 01 (2.16.11) - added textfield methods: tween(), alphaTo(),
=                                colorTo(), rotateTo(), slideTo(), scaleTo(),
=                                as well as stopTween(), lockTween(),
=                                unlockTween(), getTweens(), isTweening(),
=                                AND a new one, scrollTo()
=             may 23 (2.16.12) - added *real* synchronization for tweenings
=                                issued on the same frame (thanks to laco)
=             jun 22 (2.16.13) - rewrote colorTransformTo() in a more cleaner,
=                                intelligent and faster way - and fixed the
=                                inability to issue multiple colorTransformTo()
=                                calls (thanks to Martin Klasson for finding
=                                this error)
=                    (2.16.14) - rewrote part of the property set algorithm,
=                                making it clearer and more logic, as well as
=                                the textfield.colorTo() method (fixed a
=                                potential bug for sequential calls)
=             jul 17 (2.16.15) - fixed elastic equations problems that'd
=                                appear on flash mx 2004 when exporting a
=                                version 7 swf - updated to Robert Penner's own
=                                solution, in fact (thanks BrianWaters for
=                                pointing that out)
=             aug 17 (2.17.15) - added sound methods: tween(), stopTween(),
=                                getTweens(), isTweening(), lockTween(),
=                                unlockTween() AND two new ones, volumeTo() and
=                                panTo(), for volume and panning tweens that
=                                can be applied to sound objects
=             oct 20 (2.18.15) - added bezierSlideTo(), which does a slideTo()
=                                using a bezier control point to do a curve
=                                path - similar to curveTo()'s parameters.
=                                based on Robert Penner's pointOnCurve method:
=                                http://actionscript-toolbox.com/samplemx_pathguide.php
=             nov 28 (2.18.16) - cleaned comments and removed syntax help since
=                                nobody reads it anyways, moved to the new site
=                    (2.18.17) - added _global.$stopTween() -- handler method
=                                for *all* tweening stops (from stopTween() and
=                                for internal tween ends). this makes the code
=                                a bit more cleaner and fix some old variable
=                                leaks on stopTween()
=                    (2.18.18) - removed some legacy, non-needed code
=                    (2.18.19) - fixed ASSetPropFlags for findPointOnCurve()
=             dec 14 (2.18.20) - avoids tweening deleted objects, and removes
=                                the tween data altogether
=             dec 29 (2.19.20) - added xScaleTo(), yScaleTo(), xSlideTo() and
=                                ySlideTo - simple shortcuts, for readability's
=                                sake
=                    (2.19.21) - added the ability do to a colorTo(null) - that
=                                will restore a MovieClip's original color,
=                                with no tinting at all. This has no effect on
=                                TextFields.
=                    (2.19.22) - made it possible to use a colorTransformObject
=                                as the parameter on the colorTransformTo()
=                                method, so it detects if you are using a lot
=                                of numbers as the parameter or just an object.
=                                (thanks to rdoyle720 for the suggestion)
=             dec 31 (2.19.23) - fixed: callbacks were not executed sometimes
=                                because of the new tween end control (small
=                                typing error) :/
=       (2005) jan 3 (2.19.24) - fixed: other error when calling stopTween()
=                                with no parameters
=             jan 12 (2.20.24) - added frameTo() -- a kind of a gotoAndPlay()
=                                with equations, suggested by Martin Claesson
=                                some time ago (sorry it took so long)
=                    (2.21.24) - added *outin equations too (so now you have
=                                easeoutexpo, easeinexpo, easeinoutexpo, and
=                                the new easeoutinexpo, for example)
=             feb 08 (2.21.25) - added error warning when trying to use an
=                                animation type that doesn't exist
=             feb 16 (2.22.25) - added pauseTween() and resumeTween()! both
=                                accept a property name (string) or a list of
=                                property names (several strings, or an array
=                                of strings) as parameter
=                    (2.22.26) - made stopTween() also allow several string
=                                arguments instead of requiring an array
=             feb 17 (2.23.26) - added new events: onTweenUpdate (called after
=                                each property change) and onTweenComplete
=                                (called when an specific tween is completed)
=             mar 07 (2.24.26) - re-reorganization of the internal code: moved
=                                all core code out of the tweening methods
=                                themselves: added internal $addTween(),
=                                $updateTweens(), $createTweenController() and
=                                $removeTweenController()
=                    (2.24.27) - minor fix for speed on $stopTween()
=                    (2.25.27) - fixed the inability to do sequential
=                                bezierSlideTo() calls - a whole bunch of code
=                                was missing to allow data to be carried
=                                through different tweens correctly
=                    (2.26.27) - added option to use rounded values when
=                                updating; this is for internal use only, but
=                                it means that new sliding methods that snap to
=                                rounded pixels have been added: roundedTween(),
=                                roundedSlideTo(), roundedXSlideTo(),
=                                roundedYSlideTo(), and roundedBezierSlideTo()
=             sep 21 (2.26.28) - undefined or 0 in time apply value immediately
=                    (2.27.28) - Flash 8 compatible filters (AS1 and AS2) for
=                                MovieClips and TextFields: blurTo(), xBlurTo(),
=                                yBlurTo(), xyBlurTo(), glowTo(), xGlowTo(),
=                                yGlowTo(), xyGlowTo(), bevelTo(), xyBevelTo()
=             dec 16 (2.27.29) - fixed an issue with stopTween() and multiple
=                                parameters when using AS2 (thanks Henrique for
=                                noticing that)
=      (2006) mar 15 (2.28.29) - added resizeTo(), suggested by Simon Frankart
=                              - updated license for Robert Penner's equations
===============================================================================
*/

/*
===============================================================================
Other disclaimers
-------------------------------------------------------------------------------
All easing equations used here (and a few other auxiliary functions) are
based on Robert Penner's work. To find more information:

http://www.robertpenner.com/easing/

What follows is the equation use's license:
-------------------------------------------------------------------------------
TERMS OF USE - EASING EQUATIONS

Open source under the BSD License.

Copyright © 2001 Robert Penner
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

 * Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.
 * Neither the name of the author nor the names of contributors may be used to
   endorse or promote products derived from this software without specific
   prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------------
*/

/*
===============================================================================
REAL HIDDEN METHODS/FUNCTIONS
-------------------------------------------------------------------------------
These functions are the real core of MC Tween. They control all tweenings, and
are kept separated from the methods themselves for organization's sake.
-------------------------------------------------------------------------------
*/

_global.$createTweenController = function() {
	// INTERNAL USE: Creates the tween controller that will do all tween updates remotely
	if( not $hasTweeningSupport){
		var tweenHolder = _root.createEmptyMovieClip ("__tweenController__", 123432); // Any level
		tweenHolder.$_tweenPropList = new Array();  // Will hold the list of properties beeing tweened. an array of objects.
		tweenHolder.$_tTime = getTimer();
		tweenHolder.onEnterFrame = _global.$updateTweens;
		_global.$hasTweeningSupport = true;
	}
};
ASSetPropFlags(_global, "$createTweenController", 1, 0);

_global.$removeTweenController = function() {
	// INTERNAL USE: Destroys the tween controller in a centralized, clean, functional and paranoid way
	delete _root.__tweenController__.$_tweenPropList;
	delete _root.__tweenController__.$_tTime;
	delete _root.__tweenController__.onEnterFrame;
	_root.__tweenController__.removeMovieClip();
};
ASSetPropFlags(_global, "$removeTweenController", 1, 0);

_global.$addTween = function(mtarget, prop, propDest, timeSeconds, animType, delay, callback, extra1, extra2, extras) {
	// INTERNAL USE: Adds a new tween for an object

	// Sets default values if undefined/invalid
	if (timeSeconds == undefined) timeSeconds = 0; // default time length
	if (animType == undefined || animType == "") animType = "easeOutExpo"; // default equation!
	if (delay == undefined) delay = 0; // default delay

	// Starts tweening.. prepares to create handling mcs
	// Faster this way
	if (typeof(prop) == "string") {
		// Single property
		var properties = [prop]; // Properties, as in "_x"
		var oldProperties = [mtarget[prop]]; // Old value, as in 0
		var newProperties = [propDest]; // New (target) value, as in 100
	} else {
		// Array of properties
		// ****Hm.. this looks strange... test concat() for speed?
		var properties = []; // Properties, as in "_x"
		var oldProperties = []; // Old value, as in 0
		var newProperties = []; // New (target) value, as in 100
		for (var i in prop) oldProperties.push (mtarget[prop[i]]);
		for (var i in prop) properties.push (prop[i]);
		for (var i in propDest) newProperties.push (propDest[i]);
	}

	var $_callback_assigned = false; // 1.7.4: Knows if callback has already been assigned to an object

	// Checks if the master movieClip (which controls all tweens) exists, if not creates it
	if (_root.__tweenController__ == undefined) _global.$createTweenController();

	var tweenPropList = _root.__tweenController__.$_tweenPropList;

	// Now set its data (adds to the list of properties being tweened)
	var tTime = _root.__tweenController__.$_tTime; // 2.16.12: laco's suggestion, for a REAL uniform time
	for (var i in oldProperties) {
		// Set one new object for each property that should be tweened
		if (newProperties[i] != undefined && !mtarget.$_isTweenLocked) {
			// Only creates tweenings for properties that are not undefined. That way,
			// certain properties can be optional on the shortcut functions even though
			// they are passed to the tweening function - they're just ignored

			// Checks if it's at the tween list already
			if (mtarget.$_tweenCount > 0) {
				for (var pti=0; pti<tweenPropList.length; pti++) {
					if (tweenPropList[pti]._targ == mtarget && tweenPropList[pti]._prop == properties[i]) {
						// Exists for the same property... checks if the time is the same (if the NEW's start time would be before the OLD's ending time)
						if (tTime + (delay*1000) < tweenPropList[pti]._timeDest) {
							// It's a property that is already being tweened, BUT has already started, so it's ok to overwrite.
							// So it deletes the old one(s) and THEN creates the new one.
							tweenPropList.splice(pti, 1);
							pti--;
							mtarget.$_tweenCount--;
						}
					}
				}
			}

			// Finally, adds the new tween data to the list
			tweenPropList.push ({
				_prop       : properties[i],
				_targ       : mtarget,
				_propStart  : undefined,		// was "oldProperties[i]" (2.14.9). Doesn't set: it must be read at the first update time, to allow animating with correct [new] values when using the delay parameter
				_propDest   : newProperties[i],
				_timeStart  : tTime,
				_timeDest   : tTime+(timeSeconds*1000),
				_animType   : animType,
				_extra1     : extra1,
				_extra2     : extra2,
				_extras     : extras,			// 2.25.27: 'extras' for more tween-related data
				_delay      : delay,
				_isPaused   : false,			// whether it's paused or not
				_timePaused : 0,				// the time it has been paused
				_callback   : $_callback_assigned ? undefined : callback
			});
			// $tweenCount is used for a faster start
			mtarget.$_tweenCount = mtarget.$_tweenCount > 0 ? mtarget.$_tweenCount+1 : 1; // to avoid setting ++ to undefined
			$_callback_assigned = true; // 1.7.4
		}
	}

	// Hides stuff from public view on the movieclip being tweened
	ASSetPropFlags(mtarget, "$_tweenCount", 1, 0); // List of stuff being tweened
};
ASSetPropFlags(_global, "$addTween", 1, 0);

_global.$updateTweens = function() {
	// INTERNAL USE: This is ran every frame to update *all* existing tweens

	// On each pass, it should check and update the properties
	var tTime = this.$_tTime = getTimer();
	for (var i=0; i<this.$_tweenPropList.length; i++) {
		var objProp = this.$_tweenPropList[i]; // Temporary shortcut to this property controller object
		if (objProp._targ.toString() == undefined) {
			// Object doesn't exist anymore; so just remove it from the list (2.18.20)
			// There's no point in trying to do a clean removal through _global.$stopTween(), so just gets deleted
			this.$_tweenPropList.splice(i,1);
			i--;
		} else {
			if (objProp._timeStart + (objProp._delay*1000) <= tTime && !objProp._isPaused) {
				// Starts tweening already
				// Some of the lines below seem weird because of the nested if/elseif blocks.
				// That's because this is meant to be *fast*, not to be readable, so I've chosen to avoid unnecesssary if() checks when possible

				// "first-time" update to allow dinamically changed values for delays (2.14.9)
				if (objProp._propStart == undefined) {
					if (objProp._prop.substr(0, 10) == "__special_") {
						// Special hard-coded cases

						// 'Advanced' movieclip coloring -------------------------------------------------------------
						if (objProp._prop == "__special_mc_frame__") {
							objProp._propStart = objProp._targ._currentframe;
						} else if (objProp._prop == "__special_mc_ra__") {
							objProp._propStart = new Color (objProp._targ).getTransform().ra;
						} else if (objProp._prop == "__special_mc_rb__") {
							objProp._propStart = new Color (objProp._targ).getTransform().rb;
						} else if (objProp._prop == "__special_mc_ga__") {
							objProp._propStart = new Color (objProp._targ).getTransform().ga;
						} else if (objProp._prop == "__special_mc_gb__") {
							objProp._propStart = new Color (objProp._targ).getTransform().gb;
						} else if (objProp._prop == "__special_mc_ba__") {
							objProp._propStart = new Color (objProp._targ).getTransform().ba;
						} else if (objProp._prop == "__special_mc_bb__") {
							objProp._propStart = new Color (objProp._targ).getTransform().bb;
						} else if (objProp._prop == "__special_mc_aa__") {
							objProp._propStart = new Color (objProp._targ).getTransform().aa;
						} else if (objProp._prop == "__special_mc_ab__") {
							objProp._propStart = new Color (objProp._targ).getTransform().ab;

						// Text color --------------------------------------------------------------------------------
						} else if (objProp._prop == "__special_text_r__") {
							objProp._propStart = objProp._targ.textColor >> 16;
						} else if (objProp._prop == "__special_text_g__") {
							objProp._propStart = (objProp._targ.textColor & 0x00FF00) >> 8;
						} else if (objProp._prop == "__special_text_b__") {
							objProp._propStart = objProp._targ.textColor & 0x0000FF;

						// Sound properties --------------------------------------------------------------------------
						} else if (objProp._prop == "__special_sound_volume__") {
							objProp._propStart = objProp._targ.getVolume();
						} else if (objProp._prop == "__special_sound_pan__") {
							objProp._propStart = objProp._targ.getPan();

						// BezierSlideTo -----------------------------------------------------------------------------
						} else if (objProp._prop == "__special_bst_t__") {
							objProp._propStart = 0;
							objProp._extras.__special_bst_ix__ = objProp._targ._x;
							objProp._extras.__special_bst_iy__ = objProp._targ._y;

						// Flash 8 filters ---------------------------------------------------------------------------
						} else if (objProp._prop == "__special_blur_x__") {
							for (var j=0; j<objProp._targ.filters.length; j++) if (objProp._targ.filters[j] instanceof flash.filters.BlurFilter) objProp._propStart = objProp._targ.filters[j].blurX;
							if (objProp._propStart == undefined) objProp._propStart = 0;
						} else if (objProp._prop == "__special_blur_y__") {
							for (var j=0; j<objProp._targ.filters.length; j++) if (objProp._targ.filters[j] instanceof flash.filters.BlurFilter) objProp._propStart = objProp._targ.filters[j].blurY;
							if (objProp._propStart == undefined) objProp._propStart = 0;

						} else if (objProp._prop == "__special_glow_color__") {
							for (var j=0; j<objProp._targ.filters.length; j++) if (objProp._targ.filters[j] instanceof flash.filters.GlowFilter) objProp._propStart = objProp._targ.filters[j].color;
							if (objProp._propStart == undefined) objProp._propStart = 0xffffff;
						} else if (objProp._prop == "__special_glow_alpha__") {
							for (var j=0; j<objProp._targ.filters.length; j++) if (objProp._targ.filters[j] instanceof flash.filters.GlowFilter) objProp._propStart = objProp._targ.filters[j].alpha;
							if (objProp._propStart == undefined) objProp._propStart = 1;
						} else if (objProp._prop == "__special_glow_blurX__") {
							for (var j=0; j<objProp._targ.filters.length; j++) if (objProp._targ.filters[j] instanceof flash.filters.GlowFilter) objProp._propStart = objProp._targ.filters[j].blurX;
							if (objProp._propStart == undefined) objProp._propStart = 0;
						} else if (objProp._prop == "__special_glow_blurY__") {
							for (var j=0; j<objProp._targ.filters.length; j++) if (objProp._targ.filters[j] instanceof flash.filters.GlowFilter) objProp._propStart = objProp._targ.filters[j].blurY;
							if (objProp._propStart == undefined) objProp._propStart = 0;
						} else if (objProp._prop == "__special_glow_strength__") {
							for (var j=0; j<objProp._targ.filters.length; j++) if (objProp._targ.filters[j] instanceof flash.filters.GlowFilter) objProp._propStart = objProp._targ.filters[j].strength;
							if (objProp._propStart == undefined) objProp._propStart = 1;

						} else if (objProp._prop == "__special_bevel_distance__") {
							for (var j=0; j<objProp._targ.filters.length; j++) if (objProp._targ.filters[j] instanceof flash.filters.BevelFilter) objProp._propStart = objProp._targ.filters[j].distance;
							if (objProp._propStart == undefined) objProp._propStart = 0;
						} else if (objProp._prop == "__special_bevel_angle__") {
							for (var j=0; j<objProp._targ.filters.length; j++) if (objProp._targ.filters[j] instanceof flash.filters.BevelFilter) objProp._propStart = objProp._targ.filters[j].angle;
							if (objProp._propStart == undefined) objProp._propStart = 45;
						} else if (objProp._prop == "__special_bevel_highlightColor__") {
							for (var j=0; j<objProp._targ.filters.length; j++) if (objProp._targ.filters[j] instanceof flash.filters.BevelFilter) objProp._propStart = objProp._targ.filters[j].highlightColor;
							if (objProp._propStart == undefined) objProp._propStart = 0xffffff;
						} else if (objProp._prop == "__special_bevel_highlightAlpha__") {
							for (var j=0; j<objProp._targ.filters.length; j++) if (objProp._targ.filters[j] instanceof flash.filters.BevelFilter) objProp._propStart = objProp._targ.filters[j].highlightAlpha;
							if (objProp._propStart == undefined) objProp._propStart = 1;
						} else if (objProp._prop == "__special_bevel_shadowColor__") {
							for (var j=0; j<objProp._targ.filters.length; j++) if (objProp._targ.filters[j] instanceof flash.filters.BevelFilter) objProp._propStart = objProp._targ.filters[j].shadowColor;
							if (objProp._propStart == undefined) objProp._propStart = 0x000000;
						} else if (objProp._prop == "__special_bevel_shadowAlpha__") {
							for (var j=0; j<objProp._targ.filters.length; j++) if (objProp._targ.filters[j] instanceof flash.filters.BevelFilter) objProp._propStart = objProp._targ.filters[j].shadowAlpha;
							if (objProp._propStart == undefined) objProp._propStart = 1;
						} else if (objProp._prop == "__special_bevel_blurX__") {
							for (var j=0; j<objProp._targ.filters.length; j++) if (objProp._targ.filters[j] instanceof flash.filters.BevelFilter) objProp._propStart = objProp._targ.filters[j].blurX;
							if (objProp._propStart == undefined) objProp._propStart = 0;
						} else if (objProp._prop == "__special_bevel_blurY__") {
							for (var j=0; j<objProp._targ.filters.length; j++) if (objProp._targ.filters[j] instanceof flash.filters.BevelFilter) objProp._propStart = objProp._targ.filters[j].blurY;
							if (objProp._propStart == undefined) objProp._propStart = 0;
						} else if (objProp._prop == "__special_bevel_strength__") {
							for (var j=0; j<objProp._targ.filters.length; j++) if (objProp._targ.filters[j] instanceof flash.filters.BevelFilter) objProp._propStart = objProp._targ.filters[j].strength;
							if (objProp._propStart == undefined) objProp._propStart = 1;

						// ...Something else (hardly) ----------------------------------------------------------------
						} else {
							objProp._propStart = objProp._targ[objProp._prop];
						}
					} else {
						// Normal cases
						objProp._propStart = objProp._targ[objProp._prop];
					}
				}

				var endTime = objProp._timeDest + (objProp._delay*1000);
				if (endTime <= tTime) {
					// Finished, just use the end value for the last update
					var newValue = objProp._propDest;
				} else {
					// Continue, in-tween
					var newValue = _global.findTweenValue (objProp._propStart, objProp._propDest, objProp._timeStart, tTime-(objProp._delay*1000), objProp._timeDest, objProp._animType, objProp._extra1, objProp._extra2);
				}

				// sets the property value... this is done to have a 'correct' value in the target object

				objProp._targ[objProp._prop] = objProp._extras.mustRound ? Math.round(newValue) : newValue; // 2.26.27: option for rounded

				// special hard-coded case for movieclip color transformation...
				if (objProp._prop == "__special_mc_frame__") {
					objProp._targ.gotoAndStop(Math.round(newValue));
				} else if (objProp._prop == "__special_mc_ra__") {
					new Color(objProp._targ).setTransform({ra:newValue});
				} else if (objProp._prop == "__special_mc_rb__") {
					new Color(objProp._targ).setTransform({rb:newValue});
				} else if (objProp._prop == "__special_mc_ga__") {
					new Color(objProp._targ).setTransform({ga:newValue});
				} else if (objProp._prop == "__special_mc_gb__") {
					new Color(objProp._targ).setTransform({gb:newValue});
				} else if (objProp._prop == "__special_mc_ba__") {
					new Color(objProp._targ).setTransform({ba:newValue});
				} else if (objProp._prop == "__special_mc_bb__") {
					new Color(objProp._targ).setTransform({bb:newValue});
				} else if (objProp._prop == "__special_mc_aa__") {
					new Color(objProp._targ).setTransform({aa:newValue});
				} else if (objProp._prop == "__special_mc_ab__") {
					new Color(objProp._targ).setTransform({ab:newValue});
				}

				// special hard-coded case for bezierSlideTos
				if (objProp._prop == "__special_bst_t__") {
					var extras = objProp._extras;
					var po = _global.findPointOnCurve (extras.__special_bst_ix__, extras.__special_bst_iy__, extras.__special_bst_cx__, extras.__special_bst_cy__, extras.__special_bst_dx__, extras.__special_bst_dy__, newValue);
					if (objProp._extras.mustRound) {
						// 2.26.27: rounded positions
						objProp._targ._x = Math.round(po.x);
						objProp._targ._y = Math.round(po.y);
					} else {
						// Normal positions
						objProp._targ._x = po.x;
						objProp._targ._y = po.y;
					}
				}

				// special hard-coded case for textfield color...
				if (typeof(objProp._targ) != "movieclip" && (objProp._prop == "__special_text_b__")) {
					// Special case: textfield, B value for textColor value. B being the last one to update, so also set the textfield's textColor
					objProp._targ.textColor = (objProp._targ.__special_text_r__ << 16) + (objProp._targ.__special_text_g__ << 8) + objProp._targ.__special_text_b__;
				}

				// special hard-coded case for sound volume...
				if (objProp._prop == "__special_sound_volume__") objProp._targ.setVolume(newValue);
				if (objProp._prop == "__special_sound_pan__") objProp._targ.setPan(newValue);

				// special hard-coded case for filters
				if (objProp._prop == "__special_blur_x__") 			_global.$setFilterProperty (objProp._targ, "blur_blurX", newValue, objProp._extras);
				if (objProp._prop == "__special_blur_y__") 			_global.$setFilterProperty (objProp._targ, "blur_blurY", newValue, objProp._extras);

				if (objProp._prop == "__special_glow_color__")		_global.$setFilterProperty (objProp._targ, "glow_color", _global.findTweenColor(objProp, tTime), objProp._extras);
				if (objProp._prop == "__special_glow_alpha__")		_global.$setFilterProperty (objProp._targ, "glow_alpha", newValue, objProp._extras);
				if (objProp._prop == "__special_glow_blurX__")		_global.$setFilterProperty (objProp._targ, "glow_blurX", newValue, objProp._extras);
				if (objProp._prop == "__special_glow_blurY__")		_global.$setFilterProperty (objProp._targ, "glow_blurY", newValue, objProp._extras);
				if (objProp._prop == "__special_glow_strength__")	_global.$setFilterProperty (objProp._targ, "glow_strength", newValue, objProp._extras);

				if (objProp._prop == "__special_bevel_distance__")			_global.$setFilterProperty (objProp._targ, "bevel_distance", newValue, objProp._extras);
				if (objProp._prop == "__special_bevel_angle__")				_global.$setFilterProperty (objProp._targ, "bevel_angle", newValue, objProp._extras);
				if (objProp._prop == "__special_bevel_highlightColor__")	_global.$setFilterProperty (objProp._targ, "bevel_highlightColor", _global.findTweenColor(objProp, tTime), objProp._extras);
				if (objProp._prop == "__special_bevel_highlightAlpha__")	_global.$setFilterProperty (objProp._targ, "bevel_highlightAlpha", newValue, objProp._extras);
				if (objProp._prop == "__special_bevel_shadowColor__")		_global.$setFilterProperty (objProp._targ, "bevel_shadowColor", _global.findTweenColor(objProp, tTime), objProp._extras);
				if (objProp._prop == "__special_bevel_shadowAlpha__")		_global.$setFilterProperty (objProp._targ, "bevel_shadowAlpha", newValue, objProp._extras);
				if (objProp._prop == "__special_bevel_blurX__")				_global.$setFilterProperty (objProp._targ, "bevel_blurX", newValue, objProp._extras);
				if (objProp._prop == "__special_bevel_blurY__")				_global.$setFilterProperty (objProp._targ, "bevel_blurY", newValue, objProp._extras);
				if (objProp._prop == "__special_bevel_strength__")			_global.$setFilterProperty (objProp._targ, "bevel_strength", newValue, objProp._extras);

				// 2.23.26: calls the update event, if any
				if (objProp._targ.onTweenUpdate != undefined) {
					objProp._targ.onTweenUpdate(objProp._prop);
				}

				if (endTime <= tTime) {
					// Past the destiny time: ended.

					// 2.23.26: calls the completion event, if any
					if (objProp._targ.onTweenComplete != undefined) {
						objProp._targ.onTweenComplete(objProp._prop);
					}

					_global.$stopTween (objProp._targ, [objProp._prop], false);

					// Removes from the tweening properties list array. So simpler than the previous versions :)
					// (objProp still exists so it works further on)
					//  this.$_tweenPropList.splice(i,1); // 2.18.17 -- not needed anymore, controlled on _global.stopTween()
					i--;

					if (objProp._callback != undefined) {
						// Calls the _callback function
						if (_global.backwardCallbackTweening) {
							// Old style, for compatibility.
							// IF YOU'RE USING AN OLD VERSION AND WANT BACKWARD COMPATIBILITY, use this line:
							// _global.backwardCallbackTweening = true;
							// ON YOUR MOVIES AFTER (or before) THE #INCLUDE STATEMENT.
							var childMC = objProp._targ.createEmptyMovieClip("__child__", 122344);
							objProp._callback.apply(childMC, null);
							childMC.removeMovieClip();
						} else {
							// New method for 2.12.9: use the mc scope
							// So simpler. I should have done this from the start...
							// ...instead of trying the impossible (using the scope from which the tween was called)
							objProp._callback.apply(objProp._targ, null);
						}
					}
				}
			}
		}
	}
	// Deletes the tween controller movieclip if no tweens are left
	if (this.$_tweenPropList.length == 0) _global.$removeTweenController();
};
ASSetPropFlags(_global, "$updateTween", 1, 0);

_global.$stopTween = function(mtarget, props, wipeFuture) {
	// INTERNAL USE: Removes tweening immediately, deleting it

	// wipeFuture = removes future, non-executed tweenings too
	var tweenPropList = _root.__tweenController__.$_tweenPropList;
	var _prop;
	// Deletes it
	for (var pti in tweenPropList) {
		_prop = tweenPropList[pti]._prop;
		for (var i=0; i<props.length || (i<1 && props == undefined); i++) {
			if (tweenPropList[pti]._targ == mtarget && (_prop == props[i] || props == undefined) && (wipeFuture || tweenPropList[pti]._timeDest+(tweenPropList[pti]._delay*1000) <= getTimer())) {
				// Removes auxiliary vars
				switch (_prop) {
				case "__special_mc_frame__":
				case "__special_mc_ra__":
                case "__special_mc_rb__":
                case "__special_mc_ga__":
                case "__special_mc_gb__":
                case "__special_mc_ba__":
                case "__special_mc_bb__":
                case "__special_mc_aa__":
                case "__special_mc_ab__":
                case "__special_sound_volume__":
				case "__special_bst_t__":
					delete mtarget[_prop];
					break;
				case "__special_text_b__":
					delete mtarget.__special_text_r__;
					delete mtarget.__special_text_g__;
					delete mtarget.__special_text_b__;
					break;
				}
				// Removes from the list
				tweenPropList.splice(pti, 1);
			}
		}
	}
	// Updates the tween count "cache"
	if (props == undefined) {
		delete (mtarget.$_tweenCount);
	} else {
		mtarget.$_tweenCount = 0;
		for (var pti in tweenPropList) {
			if (tweenPropList[pti]._targ == mtarget) mtarget.$_tweenCount++;
		}
		if (mtarget.$_tweenCount == 0) delete mtarget.$_tweenCount;
	}
	// Check if the tween movieclip controller should still exist
	if (tweenPropList.length == 0) {
		// No tweenings remain, remove it
		_global.$removeTweenController();
	}
};
ASSetPropFlags(_global, "$stopTween", 1, 0);

_global.$setFilterProperty = function(mtarget, propName, propValue, extras) {
	// Sets a property for a Flash 8-based filter.
	// This is needed because you can't modify the .filter property directly; you have to re-apply it,
	// and to do so in a non-destructible way (without erasing the previous filters) the array must
	// be cloned...
	var i;
	var applied = false;

	// Creates a copy of .filters 
	var newFilters = [];
	for (var i=0; i<mtarget.filters.length; i++) {
		newFilters.push(mtarget.filters[i]);
	}

	// Finally replaces it. This looks a bit weird, I know...
	// I'll have to rewrite this later. I'm think which would be the best approach; this is too hardcoded.
	if (propName.substr(0, 5) == "blur_") {
		// Blur...
		for (i=0; i<mtarget.filters.length; i++) {
			if (newFilters[i] instanceof flash.filters.BlurFilter) {
				newFilters[i][propName.substr(5)] = propValue;
				if (extras.__special_blur_quality__ != undefined) newFilters[i].quality = extras.__special_blur_quality__; // Applies quality
				applied = true;
				break;
			}
		}
		if (!applied) {
			// Creates a new filter and applies it
			var myFilter;
			var quality = extras.__special_blur_quality__ == undefined ? 2 : extras.__special_blur_quality__; // Quality
			if (propName == "blur_blurX") myFilter = new flash.filters.BlurFilter(propValue, 0, quality);
			if (propName == "blur_blurY") myFilter = new flash.filters.BlurFilter(0, propValue, quality);
			newFilters.push(myFilter);
		}
	} else if (propName.substr(0, 5) == "glow_") {
		// Glow...
		for (i=0; i<mtarget.filters.length; i++) {
			if (newFilters[i] instanceof flash.filters.GlowFilter) {
				newFilters[i][propName.substr(5)] = propValue;
				if (extras.__special_glow_quality__ != undefined) newFilters[i].quality = extras.__special_glow_quality__; // Applies quality
				if (extras.__special_glow_inner__!= undefined) newFilters[i].inner = extras.__special_glow_inner__; // Applies inner
				if (extras.__special_glow_knockout__ != undefined) newFilters[i].knockout = extras.__special_glow_knockout__; // Applies knockout
				applied = true;
				break;
			}
		}
		if (!applied) {
			// Creates a new filter and applies it
			var myFilter;
			var quality = extras.__special_glow_quality__ == undefined ? 2 : extras.__special_glow_quality__; // Quality
			var inner = extras.__special_glow_inner__ == undefined ? false : extras.__special_glow_inner__; // Inner
			var knockout = extras.__special_glow_knockout__ == undefined ? false : extras.__special_glow_knockout__; // Knockout
			if (propName == "glow_color") myFilter = new flash.filters.GlowFilter(propValue, 1, 0, 0, 1, quality, inner, knockout);
			if (propName == "glow_alpha") myFilter = new flash.filters.GlowFilter(0xffffff, propValue, 0, 0, 1, quality, inner, knockout);
			if (propName == "glow_blurX") myFilter = new flash.filters.GlowFilter(0xffffff, 1, propValue, 0, 1, quality, inner, knockout);
			if (propName == "glow_blurY") myFilter = new flash.filters.GlowFilter(0xffffff, 1, 0, propValue, 1, quality, inner, knockout);
			if (propName == "glow_strength") myFilter = new flash.filters.GlowFilter(0xffffff, 1, 0, 0, propValue, quality, inner, knockout);
			newFilters.push(myFilter);
		}
	} else if (propName.substr(0, 6) == "bevel_") {
		// Bevel...
		for (i=0; i<mtarget.filters.length; i++) {
			if (newFilters[i] instanceof flash.filters.BevelFilter) {
				newFilters[i][propName.substr(6)] = propValue;
				if (extras.__special_bevel_quality__ != undefined) newFilters[i].quality = extras.__special_bevel_quality__; // Applies quality
				if (extras.__special_bevel_type__!= undefined) newFilters[i].inner = extras.__special_bevel_type__; // Applies type
				if (extras.__special_bevel_knockout__ != undefined) newFilters[i].knockout = extras.__special_bevel_knockout__; // Applies knockout
				applied = true;
				break;
			}
		}
		if (!applied) {
			// Creates a new filter and applies it
			var myFilter;
			var quality = extras.__special_bevel_quality__ == undefined ? 2 : extras.__special_bevel_quality__; // Quality
			var type = extras.__special_bevel_type__ == undefined ? "inner" : extras.__special_bevel_type__; // Inner
			var knockout = extras.__special_bevel_knockout__ == undefined ? false : extras.__special_bevel_knockout__; // Knockout
			if (propName == "bevel_distance") myFilter = new flash.filters.BevelFilter(propValue, 45, 0xffffff, 1, 0x000000, 1, 0, 0, 1, quality, type, knockout);
			if (propName == "bevel_angle") myFilter = new flash.filters.BevelFilter(0, propValue, 0xffffff, 1, 0x000000, 1, 0, 0, 1, quality, type, knockout);
			if (propName == "bevel_highlightColor") myFilter = new flash.filters.BevelFilter(0, 45, propValue, 1, 0x000000, 1, 0, 0, 1, quality, type, knockout);
			if (propName == "bevel_highlightAlpha") myFilter = new flash.filters.BevelFilter(0, 45, 0xffffff, propValue, 0x000000, 1, 0, 0, 1, quality, type, knockout);
			if (propName == "bevel_shadowColor") myFilter = new flash.filters.BevelFilter(0, 45, 0xffffff, 1, propValue, 1, 0, 0, 1, quality, type, knockout);
			if (propName == "bevel_shadowAlpha") myFilter = new flash.filters.BevelFilter(0, 45, 0xffffff, 1, 0x000000, propValue, 0, 0, 1, quality, type, knockout);
			if (propName == "bevel_blurX") myFilter = new flash.filters.BevelFilter(0, 45, 0xffffff, 1, 0x000000, 1, propValue, 0, 1, quality, type, knockout);
			if (propName == "bevel_blurY") myFilter = new flash.filters.BevelFilter(0, 45, 0xffffff, 1, 0x000000, 1, 0, propValue, 1, quality, type, knockout);
			if (propName == "bevel_strength") myFilter = new flash.filters.BevelFilter(0, 45, 0xffffff, 1, 0x000000, 1, 0, 0, propValue, quality, type, knockout);
			newFilters.push(myFilter);
		}
	} else {
		// Can't do anything
//		trace ("MC TWEEN ### Error on $setFilterProperty: propName \""+propName+"\" is not valid.");
		return;
	}
	// And reapplies the filter
	mtarget.filters = newFilters;
};

/*
===============================================================================
MAIN METHODS/FUNCTIONS
-------------------------------------------------------------------------------
The most basic tweening functions - for starting, stopping, pausing, etc.
-------------------------------------------------------------------------------
*/

MovieClip.prototype.tween = TextField.prototype.tween = Sound.prototype.tween = function (prop, propDest, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Starts a variable/property/attribute tween for an specific object.
	_global.$addTween(this, prop, propDest, timeSeconds, animType, delay, callback, extra1, extra2);
};
ASSetPropFlags(MovieClip.prototype, "tween", 1, 0);
ASSetPropFlags(TextField.prototype, "tween", 1, 0);
ASSetPropFlags(Sound.prototype, "tween", 1, 0);

MovieClip.prototype.roundedTween = TextField.prototype.roundedTween = Sound.prototype.roundedTween = function (prop, propDest, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Starts a variable/property/attribute tween for an specific object, and uses only rounded values when updating
	_global.$addTween(this, prop, propDest, timeSeconds, animType, delay, callback, extra1, extra2, {mustRound:true});
};
ASSetPropFlags(MovieClip.prototype, "roundedTween", 1, 0);
ASSetPropFlags(TextField.prototype, "roundedTween", 1, 0);
ASSetPropFlags(Sound.prototype, "roundedTween", 1, 0);

MovieClip.prototype.stopTween = TextField.prototype.stopTween = Sound.prototype.stopTween = function(props) {
	// Removes tweenings immediately, leaving objects as-is. Examples:
	//  <movieclip>.stopTween ("_x");          // Stops _x tweening
	//  <movieclip>.stopTween (["_x", "_y"]);  // Stops _x and _y tweening
	//  <movieclip>.stopTween ("_x", "_y");  // Stops _x and _y tweening
	//  <movieclip>.stopTween ();              // Stops all tweening processes
	if (typeof (props) == "string") props = [props]; // in case of one property, turn into array
	if (props != undefined) {
		// 2.22.26: counts all arguments as parameters too
		for (var i=1; i<arguments.length; i++) props.push(arguments[i]);
	}
	_global.$stopTween(this, props, true);
};
ASSetPropFlags(MovieClip.prototype, "stopTween", 1, 0);
ASSetPropFlags(TextField.prototype, "stopTween", 1, 0);
ASSetPropFlags(Sound.prototype, "stopTween", 1, 0);

MovieClip.prototype.pauseTween = TextField.prototype.pauseTween = Sound.prototype.pauseTween = function(props) {
	// Pauses all tweenings currently being executed for this object (this includes delayed tweenings), unless specific property names are passed as a parameter.
	//  Examples:
	//  <sound>.pauseTween();
	//  <movieclip>.pauseTween("_x");
	//  <textfield>.pauseTween("_alpha", "_y");

	if (props != undefined) {
		if (typeof (props) == "string") props = [props]; // in case of one property, turn into array
		for (var i=1; i<Arguments.length; i++) props.push(Arguments[i]);
	}

	var tweenPropList = _root.__tweenController__.$_tweenPropList;
	var mustPause;

	for (var pti in tweenPropList) {
		if (tweenPropList[pti]._targ == this && !tweenPropList[pti]._isPaused) {
			if (props != undefined) {
				// Tests if it can be stopped
				mustPause = false;
				for (var i in props) {
					if (props[i] == tweenPropList[pti]._prop) {
						mustPause = true;
						break;
					}
				}
			}
			if (props == undefined || mustPause) {
				tweenPropList[pti]._isPaused = true;
				tweenPropList[pti]._timePaused = _root.__tweenController__.$_tTime;
			}
		}
	}
};
ASSetPropFlags(MovieClip.prototype, "pauseTween", 1, 0);
ASSetPropFlags(TextField.prototype, "pauseTween", 1, 0);
ASSetPropFlags(Sound.prototype, "pauseTween", 1, 0);

MovieClip.prototype.resumeTween = TextField.prototype.resumeTween = Sound.prototype.resumeTween = function(props) {
	// Resumes all tweenings currently paused for this object, unless specific property names are passed as a parameter.

	if (props != undefined) {
		if (typeof (props) == "string") props = [props]; // in case of one property, turn into array
		for (var i=1; i<Arguments.length; i++) props.push(Arguments[i]);
	}

	var tweenPropList = _root.__tweenController__.$_tweenPropList;
	var mustResume;
	var offsetTime;

	for (var pti in tweenPropList) {
		if (tweenPropList[pti]._targ == this && tweenPropList[pti]._isPaused) {
			if (props != undefined) {
				// Tests if it can be resumed
				mustResume = false;
				for (var i in props) {
					if (props[i] == tweenPropList[pti]._prop) {
						mustResume = true;
						break;
					}
				}
			}
			if (props == undefined || mustResume) {
				tweenPropList[pti]._isPaused = false;
				offsetTime = _root.__tweenController__.$_tTime - tweenPropList[pti]._timePaused;
				tweenPropList[pti]._timeStart += offsetTime;
				tweenPropList[pti]._timeDest += offsetTime;
				tweenPropList[pti]._timePaused = 0;
			}
		}
	}
};
ASSetPropFlags(MovieClip.prototype, "resumeTween", 1, 0);
ASSetPropFlags(TextField.prototype, "resumeTween", 1, 0);
ASSetPropFlags(Sound.prototype, "resumeTween", 1, 0);

MovieClip.prototype.lockTween = TextField.prototype.lockTween = Sound.prototype.lockTween = function() {
	// Locks this object for tweening
	this.$_isTweenLocked = true;
	ASSetPropFlags(this, "this.$_isTweenLocked", 1, 0);
};
ASSetPropFlags(MovieClip.prototype, "lockTween", 1, 0);
ASSetPropFlags(TextField.prototype, "lockTween", 1, 0);
ASSetPropFlags(Sound.prototype, "lockTween", 1, 0);

MovieClip.prototype.unlockTween = TextField.prototype.unlockTween = Sound.prototype.unlockTween = function() {
	// Unlocks this object for tweening
	delete (this.$_isTweenLocked);
};
ASSetPropFlags(MovieClip.prototype, "unlockTween", 1, 0);
ASSetPropFlags(TextField.prototype, "unlockTween", 1, 0);
ASSetPropFlags(Sound.prototype, "unlockTween", 1, 0);

MovieClip.prototype.getTweens = TextField.prototype.getTweens = Sound.prototype.getTweens = function() {
	// Returns the number of tweenings actually being executed
	// Tweenings are NOT overwritten, so it's possible to have a series of tweenings at the same time
	return (this.$_tweenCount);
};
ASSetPropFlags(MovieClip.prototype, "getTweens", 1, 0);
ASSetPropFlags(TextField.prototype, "getTweens", 1, 0);
ASSetPropFlags(Sound.prototype, "getTweens", 1, 0);

MovieClip.prototype.isTweening = TextField.prototype.isTweening = Sound.prototype.isTweening = function() {
	// Returns true if there's at least one tweening being executed, otherwise false
	return (this.$_tweenCount > 0 ? true : false);
};
ASSetPropFlags(MovieClip.prototype, "isTweening", 1, 0);
ASSetPropFlags(TextField.prototype, "isTweening", 1, 0);
ASSetPropFlags(Sound.prototype, "isTweening", 1, 0);


/*
===============================================================================
SHORTCUT METHODS/FUNCTIONS
-------------------------------------------------------------------------------
Start tweenings with different commands. These methods are used mostly for code
readability and special handling of some non-property attributes (like movieclip
color, sound volume, etc) but also to make the coding easier for non-expert
programmers or designers.
-------------------------------------------------------------------------------
*/

MovieClip.prototype.alphaTo = TextField.prototype.alphaTo = function (propDest_a, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Does an alpha tween. Example: <movieclip>.alphaTo(100)
	_global.$addTween(this, "_alpha", propDest_a, timeSeconds, animType, delay, callback, extra1, extra2);
};
ASSetPropFlags(MovieClip.prototype, "alphaTo", 1, 0);
ASSetPropFlags(TextField.prototype, "alphaTo", 1, 0);

MovieClip.prototype.frameTo = function(propDest_frame, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Does a frame tween - kinf of like a gotoAndPlay(), but with time and equations. Example: <movieclip>.frameTo(20, 1, "easeinoutexpo")
	_global.$addTween(this, "__special_mc_frame__", propDest_frame, timeSeconds, animType, delay, callback, extra1, extra2);
};
ASSetPropFlags(MovieClip.prototype, "frameTo", 1, 0);

MovieClip.prototype.resizeTo = TextField.prototype.resizeTo = function (propDest_width, propDest_height, timeSeconds, animType, delay, callback, extra1, extra2) {
 // Scales an object to a given width and height
 _global.$addTween(this, ["_width", "_height"], [propDest_width, propDest_height], timeSeconds, animType, delay, callback, extra1, extra2);
};
ASSetPropFlags(MovieClip.prototype, "resizeTo", 1, 0);
ASSetPropFlags(TextField.prototype, "resizeTo", 1, 0);

MovieClip.prototype.rotateTo = TextField.prototype.rotateTo = function (propDest_rotation, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Rotates an object given a degree.
	_global.$addTween(this, "_rotation", propDest_rotation, timeSeconds, animType, delay, callback, extra1, extra2);
};
ASSetPropFlags(MovieClip.prototype, "rotateTo", 1, 0);
ASSetPropFlags(TextField.prototype, "rotateTo", 1, 0);

MovieClip.prototype.scaleTo = TextField.prototype.scaleTo = function (propDest_scale, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Scales an object uniformly.
	_global.$addTween(this, ["_xscale", "_yscale"], [propDest_scale, propDest_scale], timeSeconds, animType, delay, callback, extra1, extra2);
};
ASSetPropFlags(MovieClip.prototype, "scaleTo", 1, 0);
ASSetPropFlags(TextField.prototype, "scaleTo", 1, 0);

MovieClip.prototype.xScaleTo = TextField.prototype.xScaleTo = function (propDest_scale, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Scales an object on the horizontal axis.
	_global.$addTween(this, "_xscale", propDest_scale, timeSeconds, animType, delay, callback, extra1, extra2);
};
ASSetPropFlags(MovieClip.prototype, "xScaleTo", 1, 0);
ASSetPropFlags(TextField.prototype, "xScaleTo", 1, 0);

MovieClip.prototype.yScaleTo = TextField.prototype.yScaleTo = function (propDest_scale, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Scales an object on the vertical axis.
	_global.$addTween(this, "_yscale", propDest_scale, timeSeconds, animType, delay, callback, extra1, extra2);
};
ASSetPropFlags(MovieClip.prototype, "yScaleTo", 1, 0);
ASSetPropFlags(TextField.prototype, "yScaleTo", 1, 0);

TextField.prototype.scrollTo = function (propDest_scroll, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Tweens the scroll property of a textfield.. so you can do an easing scroll to a line
	_global.$addTween(this, "scroll", propDest_scroll, timeSeconds, animType, delay, callback, extra1, extra2);
};
ASSetPropFlags(TextField.prototype, "scrollTo", 1, 0);

MovieClip.prototype.slideTo = TextField.prototype.slideTo = function (propDest_x, propDest_y, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Does a xy sliding tween. Example: <movieclip>.slideTo(100, 100)
	_global.$addTween(this, ["_x", "_y"], [propDest_x, propDest_y], timeSeconds, animType, delay, callback, extra1, extra2);
};
ASSetPropFlags(MovieClip.prototype, "slideTo", 1, 0);
ASSetPropFlags(TextField.prototype, "slideTo", 1, 0);

MovieClip.prototype.roundedSlideTo = TextField.prototype.roundedSlideTo = function (propDest_x, propDest_y, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Does a xy sliding tween on rounded pixels. Example: <movieclip>.roundedSlideTo(100, 100)
	_global.$addTween(this, ["_x", "_y"], [propDest_x, propDest_y], timeSeconds, animType, delay, callback, extra1, extra2, {mustRound:true});
};
ASSetPropFlags(MovieClip.prototype, "roundedSlideTo", 1, 0);
ASSetPropFlags(TextField.prototype, "roundedSlideTo", 1, 0);

MovieClip.prototype.xSlideTo = TextField.prototype.xSlideTo = function (propDest_x, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Does a xy sliding tween. Example: <movieclip>.slideTo(100, 100)
	_global.$addTween(this, "_x", propDest_x, timeSeconds, animType, delay, callback, extra1, extra2);
};
ASSetPropFlags(MovieClip.prototype, "xSlideTo", 1, 0);
ASSetPropFlags(TextField.prototype, "xSlideTo", 1, 0);

MovieClip.prototype.roundedXSlideTo = TextField.prototype.roundedXSlideTo = function (propDest_x, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Does a xy sliding tween. Example: <movieclip>.slideTo(100, 100)
	_global.$addTween(this, "_x", propDest_x, timeSeconds, animType, delay, callback, extra1, extra2, {mustRound:true});
};
ASSetPropFlags(MovieClip.prototype, "roundedXSlideTo", 1, 0);
ASSetPropFlags(TextField.prototype, "roundedXSlideTo", 1, 0);

MovieClip.prototype.ySlideTo = TextField.prototype.ySlideTo = function (propDest_y, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Does a xy sliding tween. Example: <movieclip>.slideTo(100, 100)
	_global.$addTween(this, "_y", propDest_y, timeSeconds, animType, delay, callback, extra1, extra2);
};
ASSetPropFlags(MovieClip.prototype, "ySlideTo", 1, 0);
ASSetPropFlags(TextField.prototype, "ySlideTo", 1, 0);

MovieClip.prototype.roundedYSlideTo = TextField.prototype.roundedYSlideTo = function (propDest_y, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Does a xy sliding tween. Example: <movieclip>.slideTo(100, 100)
	_global.$addTween(this, "_y", propDest_y, timeSeconds, animType, delay, callback, extra1, extra2, {mustRound:true});
};
ASSetPropFlags(MovieClip.prototype, "roundedYSlideTo", 1, 0);
ASSetPropFlags(TextField.prototype, "roundedYSlideTo", 1, 0);

MovieClip.prototype.bezierSlideTo = TextField.prototype.bezierSlideTo = function (cpoint_x, cpoint_y, propDest_x, propDest_y, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Does a xy sliding tween using a bezier curve, similar to the drawing api curveTo() parameters. Example: <movieclip>.slideTo(100, 100, 200, 200)
	var extras = new Object(); // New for 2.25.27: fix for several different beziers, uses an 'extras' object. Good for all general uses.
	extras.__special_bst_ix__ = undefined; // Initial X position. Has to be remembered
	extras.__special_bst_iy__ = undefined; // Initial Y position. Has to be remembered
	extras.__special_bst_cx__ = cpoint_x; // Control point X position. Has to be remembered
	extras.__special_bst_cy__ = cpoint_y; // Control point Y position. Has to be remembered
	extras.__special_bst_dx__ = propDest_x; // Final X position. Has to be remembered
	extras.__special_bst_dy__ = propDest_y; // Final Y position. Has to be remembered
	_global.$addTween(this, "__special_bst_t__", 1, timeSeconds, animType, delay, callback, extra1, extra2, extras);
};
ASSetPropFlags(MovieClip.prototype, "bezierSlideTo", 1, 0);
ASSetPropFlags(TextField.prototype, "bezierSlideTo", 1, 0);

MovieClip.prototype.roundedBezierSlideTo = TextField.prototype.roundedBezierSlideTo = function (cpoint_x, cpoint_y, propDest_x, propDest_y, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Does a xy sliding tween using a bezier curve, similar to the drawing api curveTo() parameters. Example: <movieclip>.slideTo(100, 100, 200, 200)
	var extras = new Object(); // New for 2.25.27: fix for several different beziers, uses an 'extras' object. Good for all general uses.
	extras.__special_bst_ix__ = undefined; // Initial X position. Has to be remembered
	extras.__special_bst_iy__ = undefined; // Initial Y position. Has to be remembered
	extras.__special_bst_cx__ = cpoint_x; // Control point X position. Has to be remembered
	extras.__special_bst_cy__ = cpoint_y; // Control point Y position. Has to be remembered
	extras.__special_bst_dx__ = propDest_x; // Final X position. Has to be remembered
	extras.__special_bst_dy__ = propDest_y; // Final Y position. Has to be remembered
	extras.mustRound = true;
	_global.$addTween(this, "__special_bst_t__", 1, timeSeconds, animType, delay, callback, extra1, extra2, extras);
};
ASSetPropFlags(MovieClip.prototype, "roundedBezierSlideTo", 1, 0);
ASSetPropFlags(TextField.prototype, "roundedBezierSlideTo", 1, 0);

Sound.prototype.volumeTo = function (propDest_volume, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Does a sound volume tween, 'fading' from one volume set to another (0->100)
	_global.$addTween(this, "__special_sound_volume__", propDest_volume, timeSeconds, animType, delay, callback, extra1, extra2);
};
ASSetPropFlags(Sound.prototype, "volumeTo", 1, 0);

Sound.prototype.panTo = function (propDest_volume, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Does a panning tween, 'fading' from one pan set to another (-100->100)
	_global.$addTween(this, "__special_sound_pan__", propDest_volume, timeSeconds, animType, delay, callback, extra1, extra2);
};
ASSetPropFlags(Sound.prototype, "panTo", 1, 0);

MovieClip.prototype.colorTo = function (propDest_color, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Does a simple color transformation (tint) tweening.
	// Works like Flash MX's color.setRGB method.
	//  Example: <movieclip>.colorTo(0xFF6CD9)
	// If the first parameter is null or omitted, it just resets its tinting.
	if (propDest_color == null) {
		// Just reset the colorTransformation
		this.colorTransformTo(100, 0, 100, 0, 100, 0, undefined, undefined, timeSeconds, animType, delay, callback, extra1, extra2);
	} else {
		// Just do a colorTransformTo tween, since it's a movieclip
		var new_r = propDest_color >> 16;
		var new_g = (propDest_color & 0x00FF00) >> 8;
		var new_b = propDest_color & 0x0000FF;
		this.colorTransformTo (0, new_r, 0, new_g, 0, new_b, undefined, undefined, timeSeconds, animType, delay, callback, extra1, extra2);
	}
};
ASSetPropFlags(MovieClip.prototype, "colorTo", 1, 0);

TextField.prototype.colorTo = function (propDest_color, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Does a simple color transformation (tint) tweening.
	// Works like Flash MX's color.setRGB method.
	//  Example: <textfield>.colorTo(0xFF6CD9)
	// On the textfield's case, it sets its color directly.
	var new_r = propDest_color >> 16;
	var new_g = (propDest_color & 0x00FF00) >> 8;
	var new_b = propDest_color & 0x0000FF;
	// __special_text_?__ is understood by the tweening function as being a map to its textcolor's RGB value
	_global.$addTween(this, ["__special_text_r__", "__special_text_g__", "__special_text_b__"], [new_r, new_g, new_b], timeSeconds, animType, delay, callback, extra1, extra2);
};
ASSetPropFlags(TextField.prototype, "colorTo", 1, 0);

MovieClip.prototype.colorTransformTo = function () {
	// Does a color transformation tweening, based on Flash's "advanced" color transformation settings.
	// Works like Flash MX's color.setTransform method, although it uses properties directly as parameters and not a color object
	//  Example: <movieclip>.colorTransformTo(200, 0, 200, 0, 200, 0, undefined, undefined, 2) --> 'dodged' colors
	//           <movieclip>.colorTransformTo(100, 0, 100, 0, 100, 0, 100, 0, 2)  --> 'normal' state of a movieclip
	// ra = red alpha, % of the original object's color to remain on the new object
	// rb = red offset, how much to add to the red color
	// ga, gb = same for green
	// ba, bb = same for blue
	// aa, ab = same for alpha
	if (typeof(arguments[0]) == "object" && arguments[0] != undefined) {
		// 2.19.22 :: It's a color transform object.
		_global.$addTween(this, ["__special_mc_ra__", "__special_mc_rb__", "__special_mc_ga__", "__special_mc_gb__", "__special_mc_ba__", "__special_mc_bb__", "__special_mc_aa__", "__special_mc_ab__"], [arguments[0].ra, arguments[0].rb, arguments[0].ga, arguments[0].gb, arguments[0].ba, arguments[0].bb, arguments[0].aa, arguments[0].ab], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6]);
	} else {
		// Normal parameters passed.
		_global.$addTween(this, ["__special_mc_ra__", "__special_mc_rb__", "__special_mc_ga__", "__special_mc_gb__", "__special_mc_ba__", "__special_mc_bb__", "__special_mc_aa__", "__special_mc_ab__"], [arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6], arguments[7]], arguments[8], arguments[9], arguments[10], arguments[11], arguments[12], arguments[13]);
	}
};
ASSetPropFlags(MovieClip.prototype, "colorTransformTo", 1, 0);

/*
===============================================================================
FLASH 8 FILTERS METHODS/FUNCTIONS
-------------------------------------------------------------------------------
These methods create .filters tweenings. Should only be used on Flash 8 files,
exported as either AS1 or AS2. They're a bit weird looking because the .filters
property is not modifiable - you have to create a copy of it and reapply
everything - but it works fine.
-------------------------------------------------------------------------------
*/

// Blur -------------------------

MovieClip.prototype.blurTo = TextField.prototype.blurTo = function () {
	// Creates a blur on the object.
	// 1 -> (propDest_blur, quality, timeSeconds, animType, delay, callback, extra1, extra2)
	// 2 -> (BlurFilter, timeSeconds, animType, delay, callback, extra1, extra2)
	// propDest_blur = blur, as on flash.filters.BlurFilter .blurX and .blurY parameters
	// quality = blur quality, as on flash.filters.BlurFilter .quality
	if (typeof(arguments[0]) == "object" && arguments[0] != undefined) {
		// It's an object
		_global.$addTween(this, ["__special_blur_x__","__special_blur_y__"], [arguments[0].blurX, arguments[0].blurY], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6], {__special_blur_quality__:arguments[0].quality});
	} else {
		// Normal parameters
		_global.$addTween(this, ["__special_blur_x__","__special_blur_y__"], [arguments[0], arguments[0]], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6], arguments[7], {__special_blur_quality__:arguments[1]});
	}
};
ASSetPropFlags(MovieClip.prototype, "blurTo", 1, 0);
ASSetPropFlags(TextField.prototype, "blurTo", 1, 0);

MovieClip.prototype.xyBlurTo = TextField.prototype.xyBlurTo = function (propDest_blurX, propDest_blurY, quality, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Blur with different horizontal/vertical values
	_global.$addTween(this, ["__special_blur_x__","__special_blur_y__"], [propDest_blurX, propDest_blurY], timeSeconds, animType, delay, callback, extra1, extra2, {__special_blur_quality__:quality});
};
ASSetPropFlags(MovieClip.prototype, "xyBlurTo", 1, 0);
ASSetPropFlags(TextField.prototype, "xyBlurTo", 1, 0);

MovieClip.prototype.xBlurTo = TextField.prototype.xBlurTo = function (propDest_blur, quality, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Horizontal blur
	_global.$addTween(this, "__special_blur_x__", propDest_blur, timeSeconds, animType, delay, callback, extra1, extra2, {__special_blur_quality__:quality});
};
ASSetPropFlags(MovieClip.prototype, "xBlurTo", 1, 0);
ASSetPropFlags(TextField.prototype, "xBlurTo", 1, 0);

MovieClip.prototype.yBlurTo = TextField.prototype.yBlurTo = function (propDest_blur, quality, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Vertical blur
	_global.$addTween(this, "__special_blur_y__", propDest_blur, timeSeconds, animType, delay, callback, extra1, extra2, {__special_blur_quality__:quality});
};
ASSetPropFlags(MovieClip.prototype, "yBlurTo", 1, 0);
ASSetPropFlags(TextField.prototype, "yBlurTo", 1, 0);


// Glow -------------------------

MovieClip.prototype.glowTo = TextField.prototype.glowTo = function () {
	// Applies a glow filter
	// 1 -> (propDest_color, propDest_alpha, propDest_blur, propDest_strength, quality, inner, knockout, timeSeconds, animType, delay, callback, extra1, extra2)
	// 2 -> (GlowFilter, timeSeconds, animType, delay, callback, extra1, extra2)
	if (typeof(arguments[0]) == "object" && arguments[0] != undefined) {
		// It's an object
		_global.$addTween(this, ["__special_glow_color__", "__special_glow_alpha__", "__special_glow_blurX__","__special_glow_blurY__", "__special_glow_strength__"], [arguments[0].color, arguments[0].alpha, arguments[0].blurX, arguments[0].blurY, arguments[0].strength], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6], {__special_glow_quality__:arguments[0].quality, __special_glow_inner__:arguments[0].inner, __special_glow_knockout__:arguments[0].knockout});
	} else {
		// Normal parameters
		_global.$addTween(this, ["__special_glow_color__", "__special_glow_alpha__", "__special_glow_blurX__","__special_glow_blurY__", "__special_glow_strength__"], [arguments[0], arguments[1], arguments[2], arguments[2], arguments[3]], arguments[7], arguments[8], arguments[9], arguments[10], arguments[11], arguments[12], {__special_glow_quality__:arguments[4], __special_glow_inner__:arguments[5], __special_glow_knockout__:arguments[6]});
	}

};
ASSetPropFlags(MovieClip.prototype, "glowTo", 1, 0);
ASSetPropFlags(TextField.prototype, "glowTo", 1, 0);

MovieClip.prototype.xyGlowTo = TextField.prototype.xyGlowTo = function (propDest_color, propDest_alpha, propDest_blurX, propDest_blurY, propDest_strength, quality, inner, knockout, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Applies a glow filter with different horizontal/vertical values
	_global.$addTween(this, ["__special_glow_color__", "__special_glow_alpha__", "__special_glow_blurX__","__special_glow_blurY__", "__special_glow_strength__"], [propDest_color, propDest_alpha, propDest_blurX, propDest_blurY, propDest_strength], timeSeconds, animType, delay, callback, extra1, extra2, {__special_glow_quality__:quality, __special_glow_inner__:inner, __special_glow_knockout__:knockout});
};
ASSetPropFlags(MovieClip.prototype, "xyGlowTo", 1, 0);
ASSetPropFlags(TextField.prototype, "xyGlowTo", 1, 0);

MovieClip.prototype.xGlowTo = TextField.prototype.xGlowTo = function (propDest_color, propDest_alpha, propDest_blur, propDest_strength, quality, inner, knockout, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Applies a glow filter horizontally only
	_global.$addTween(this, ["__special_glow_color__", "__special_glow_alpha__", "__special_glow_blurX__", "__special_glow_strength__"], [propDest_color, propDest_alpha, propDest_blur, propDest_strength], timeSeconds, animType, delay, callback, extra1, extra2, {__special_glow_quality__:quality, __special_glow_inner__:inner, __special_glow_knockout__:knockout});
};
ASSetPropFlags(MovieClip.prototype, "xGlowTo", 1, 0);
ASSetPropFlags(TextField.prototype, "xGlowTo", 1, 0);

MovieClip.prototype.yGlowTo = TextField.prototype.yGlowTo = function (propDest_color, propDest_alpha, propDest_blur, propDest_strength, quality, inner, knockout, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Applies a glow filter vertically only
	_global.$addTween(this, ["__special_glow_color__", "__special_glow_alpha__", "__special_glow_blurY__", "__special_glow_strength__"], [propDest_color, propDest_alpha, propDest_blur, propDest_strength], timeSeconds, animType, delay, callback, extra1, extra2, {__special_glow_quality__:quality, __special_glow_inner__:inner, __special_glow_knockout__:knockout});
};
ASSetPropFlags(MovieClip.prototype, "yGlowTo", 1, 0);
ASSetPropFlags(TextField.prototype, "yGlowTo", 1, 0);


// Bevel ------------------------

MovieClip.prototype.bevelTo = TextField.prototype.bevelTo = function () {
	// Applies a bevel filter
	// 1 -> (propDest_distance, propDest_angle, propDest_highlightColor, propDest_highlightAlpha, propDest_shadowColor, propDest_shadowAlpha, propDest_blur, propDest_strength, quality, type, knockout, timeSeconds, animType, delay, callback, extra1, extra2) {
	// 2 -> (bevelFilter, timeSeconds, animType, delay, callback, extra1, extra2) {
	if (typeof(arguments[0]) == "object" && arguments[0] != undefined) {
		// It's an object
		_global.$addTween(this, ["__special_bevel_distance__", "__special_bevel_angle__", "__special_bevel_highlightColor__","__special_bevel_highlightAlpha__", "__special_bevel_shadowColor__", "__special_bevel_shadowAlpha__", "__special_bevel_blurX__", "__special_bevel_blurY__", "__special_bevel_strength__"], [arguments[0].distance, arguments[0].angle, arguments[0].highlightColor, arguments[0].highlightAlpha*100, arguments[0].shadowColor, arguments[0].shadowAlpha*100, arguments[0].blurX, arguments[0].blurY, arguments[0].strength], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6], {__special_bevel_quality__:arguments[0].quality, __special_bevel_type__:arguments[0].type, __special_bevel_knockout__:arguments[0].knockout});
	} else {
		// Normal parameters
		_global.$addTween(this, ["__special_bevel_distance__", "__special_bevel_angle__", "__special_bevel_highlightColor__","__special_bevel_highlightAlpha__", "__special_bevel_shadowColor__", "__special_bevel_shadowAlpha__", "__special_bevel_blurX__", "__special_bevel_blurY__", "__special_bevel_strength__"], [arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6], arguments[6], arguments[7]], arguments[11], arguments[12], arguments[13], arguments[14], arguments[15], arguments[16], {__special_bevel_quality__:arguments[8], __special_bevel_type__:arguments[9], __special_bevel_knockout__:arguments[10]});
	}
};
ASSetPropFlags(MovieClip.prototype, "bevelTo", 1, 0);
ASSetPropFlags(TextField.prototype, "bevelTo", 1, 0);

MovieClip.prototype.xyBevelTo = TextField.prototype.xyBevelTo = function (propDest_distance, propDest_angle, propDest_highlightColor, propDest_highlightAlpha, propDest_shadowColor, propDest_shadowAlpha, propDest_blurX, propDest_blurY, propDest_strength, quality, type, knockout, timeSeconds, animType, delay, callback, extra1, extra2) {
	// Applies a bevel filter with different horizontal/vertical values
	_global.$addTween(this, ["__special_bevel_distance__", "__special_bevel_angle__", "__special_bevel_highlightColor__","__special_bevel_highlightAlpha__", "__special_bevel_shadowColor__", "__special_bevel_shadowAlpha__", "__special_bevel_blurX__", "__special_bevel_blurY__", "__special_bevel_blurY__", "__special_bevel_strength__"], [propDest_distance, propDest_angle, propDest_highlightColor, propDest_highlightAlpha, propDest_shadowColor, propDest_shadowAlpha, propDest_blur, propDest_blur, propDest_strength], timeSeconds, animType, delay, callback, extra1, extra2, {__special_bevel_quality__:quality, __special_bevel_type__:type, __special_bevel_knockout__:knockout});
};
ASSetPropFlags(MovieClip.prototype, "xyBevelTo", 1, 0);
ASSetPropFlags(TextField.prototype, "xyBevelTo", 1, 0);

/*
===============================================================================
CALCULATION FUNCTIONS
-------------------------------------------------------------------------------
These functions are used by others methods and functions to find the correct
values for the tweenings. They're for internal use, but can be used for several
other features out of MC Tween itself.
-------------------------------------------------------------------------------
*/

_global.findPointOnCurve = function (p1x, p1y, cx, cy, p2x, p2y, t) {
	// Returns the points on a bezier curve for a given time (t is 0-1);
	// This is based on Robert Penner's Math.pointOnCurve() function
	// More information: http://actionscript-toolbox.com/samplemx_pathguide.php
	return {x:p1x + t*(2*(1-t)*(cx-p1x) + t*(p2x - p1x)),
			y:p1y + t*(2*(1-t)*(cy-p1y) + t*(p2y - p1y))};
};
ASSetPropFlags(_global, "findPointOnCurve", 1, 0);

_global.findTweenColor = function (objProp, tTime) {
	// Quick way to recalculate color on direct color tweenings
	var rrs = objProp._propStart >> 16; // r start
	var rrd = objProp._propDest >> 16; // r destiny
	var ggs = objProp._propStart >> 8 & 0xff; // g start
	var ggd = objProp._propDest >> 8 & 0xff; // g destiny
	var bbs = objProp._propStart & 0xff; // b start
	var bbd = objProp._propDest & 0xff; // b destiny

	var newR = Math.round(_global.findTweenValue (rrs, rrd, objProp._timeStart, tTime-(objProp._delay*1000), objProp._timeDest, objProp._animType, objProp._extra1, objProp._extra2));
	var newG = Math.round(_global.findTweenValue (ggs, ggd, objProp._timeStart, tTime-(objProp._delay*1000), objProp._timeDest, objProp._animType, objProp._extra1, objProp._extra2));
	var newB = Math.round(_global.findTweenValue (bbs, bbd, objProp._timeStart, tTime-(objProp._delay*1000), objProp._timeDest, objProp._animType, objProp._extra1, objProp._extra2));

	return (newR << 16) + (newG << 8) + newB;
};

_global.findTweenValue = function (_propStart, _propDest, _timeStart, _timeNow, _timeDest, _animType, _extra1, _extra2) {
	// Returns the current value of a property mid-value given the time.
	// Used by the tween methods to see where the movieclip should be on the current
	// tweening process. All equations on this function are Robert Penner's work.
	var t = _timeNow - _timeStart;  // current time (frames, seconds)
	var b = _propStart;             // beginning value
	var c = _propDest - _propStart; // change in value
	var d = _timeDest - _timeStart; // duration (frames, seconds)
	var a = _extra1;                // amplitude (optional - used only on *elastic easing)
	var p = _extra2;                // period (optional - used only on *elastic easing)
	var s = _extra1;                // overshoot ammount (optional - used only on *back easing)

	switch (_animType.toLowerCase()) {
	case "linear":
		// simple linear tweening - no easing
		return c*t/d + b;

	case "easeinquad":
		// quadratic (t^2) easing in - accelerating from zero velocity
		return c*(t/=d)*t + b;
	case "easeoutquad":
		// quadratic (t^2) easing out - decelerating to zero velocity
		return -c *(t/=d)*(t-2) + b;
	case "easeinoutquad":
		// quadratic (t^2) easing in/out - acceleration until halfway, then deceleration
		if ((t/=d/2) < 1) return c/2*t*t + b;
		return -c/2 * ((--t)*(t-2) - 1) + b;
	case "easeoutinquad":
		// quadratic (t^2) easing out/in - deceleration until halfway, then acceleration
		if (t < d/2) return findTweenValue (0, c, 0, t*2, d, "easeOutQuad") * .5 + b;
		return findTweenValue(0, c, 0, t*2-d, d, "easeInQuad") * .5 + c*.5 + b;

	case "easeincubic":
		// cubic (t^3) easing in - accelerating from zero velocity
		return c*(t/=d)*t*t + b;
	case "easeoutcubic":
		// cubic (t^3) easing out - decelerating to zero velocity
		return c*((t=t/d-1)*t*t + 1) + b;
	case "easeinoutcubic":
		// cubic (t^3) easing in/out - acceleration until halfway, then deceleration
		if ((t/=d/2) < 1) return c/2*t*t*t + b;
		return c/2*((t-=2)*t*t + 2) + b;
	case "easeoutincubic":
		// cubic (t^3) easing out/in - deceleration until halfway, then acceleration
		if (t < d/2) return findTweenValue (0, c, 0, t*2, d, "easeOutCubic") * .5 + b;
		return findTweenValue(0, c, 0, t*2-d, d, "easeInCubic") * .5 + c*.5 + b;

	case "easeinquart":
		// quartic (t^4) easing in - accelerating from zero velocity
		return c*(t/=d)*t*t*t + b;
	case "easeoutquart":
		// quartic (t^4) easing out - decelerating to zero velocity
		return -c * ((t=t/d-1)*t*t*t - 1) + b;
	case "easeinoutquart":
		// quartic (t^4) easing in/out - acceleration until halfway, then deceleration
		if ((t/=d/2) < 1) return c/2*t*t*t*t + b;
		return -c/2 * ((t-=2)*t*t*t - 2) + b;
	case "easeoutinquart":
		// quartic (t^4) easing out/in - deceleration until halfway, then acceleration
		if (t < d/2) return findTweenValue (0, c, 0, t*2, d, "easeOutQuart") * .5 + b;
		return findTweenValue(0, c, 0, t*2-d, d, "easeInQuart") * .5 + c*.5 + b;

	case "easeinquint":
		// quintic (t^5) easing in - accelerating from zero velocity
		return c*(t/=d)*t*t*t*t + b;
	case "easeoutquint":
		// quintic (t^5) easing out - decelerating to zero velocity
		return c*((t=t/d-1)*t*t*t*t + 1) + b;
	case "easeinoutquint":
		// quintic (t^5) easing in/out - acceleration until halfway, then deceleration
		if ((t/=d/2) < 1) return c/2*t*t*t*t*t + b;
		return c/2*((t-=2)*t*t*t*t + 2) + b;
	case "easeoutinquint":
		// quintic (t^5) easing out/in - deceleration until halfway, then acceleration
		if (t < d/2) return findTweenValue (0, c, 0, t*2, d, "easeOutQuint") * .5 + b;
		return findTweenValue(0, c, 0, t*2-d, d, "easeInQuint") * .5 + c*.5 + b;

	case "easeinsine":
		// sinusoidal (sin(t)) easing in - accelerating from zero velocity
		return -c * Math.cos(t/d * (Math.PI/2)) + c + b;
	case "easeoutsine":
		// sinusoidal (sin(t)) easing out - decelerating to zero velocity
		return c * Math.sin(t/d * (Math.PI/2)) + b;
	case "easeinoutsine":
		// sinusoidal (sin(t)) easing in/out - acceleration until halfway, then deceleration
		return -c/2 * (Math.cos(Math.PI*t/d) - 1) + b;
	case "easeoutinsine":
		// sinusoidal (sin(t)) easing out/in - deceleration until halfway, then acceleration
		if (t < d/2) return findTweenValue (0, c, 0, t*2, d, "easeOutSine") * .5 + b;
		return findTweenValue(0, c, 0, t*2-d, d, "easeInSine") * .5 + c*.5 + b;

	case "easeinexpo":
		// exponential (2^t) easing in - accelerating from zero velocity
		return (t==0) ? b : c * Math.pow(2, 10 * (t/d - 1)) + b;
	case "easeoutexpo":
		// exponential (2^t) easing out - decelerating to zero velocity
		return (t==d) ? b+c : c * (-Math.pow(2, -10 * t/d) + 1) + b;
	case "easeinoutexpo":
		// exponential (2^t) easing in/out - acceleration until halfway, then deceleration
		if (t==0) return b;
		if (t==d) return b+c;
		if ((t/=d/2) < 1) return c/2 * Math.pow(2, 10 * (t - 1)) + b;
		return c/2 * (-Math.pow(2, -10 * --t) + 2) + b;
	case "easeoutinexpo":
		// exponential (2^t) easing out/in - deceleration until halfway, then acceleration
		if (t==0) return b;
		if (t==d) return b+c;
		if ((t/=d/2) < 1) return c/2 * (-Math.pow(2, -10 * t/1) + 1) + b;
		return c/2 * (Math.pow(2, 10 * (t-2)/1) + 1) + b;

	case "easeincirc":
		// circular (sqrt(1-t^2)) easing in - accelerating from zero velocity
		return -c * (Math.sqrt(1 - (t/=d)*t) - 1) + b;
	case "easeoutcirc":
		// circular (sqrt(1-t^2)) easing out - decelerating to zero velocity
		return c * Math.sqrt(1 - (t=t/d-1)*t) + b;
	case "easeinoutcirc":
		// circular (sqrt(1-t^2)) easing in/out - acceleration until halfway, then deceleration
		if ((t/=d/2) < 1) return -c/2 * (Math.sqrt(1 - t*t) - 1) + b;
		return c/2 * (Math.sqrt(1 - (t-=2)*t) + 1) + b;
	case "easeoutincirc":
		// circular (sqrt(1-t^2)) easing in/out - acceleration until halfway, then deceleration
		if (t < d/2) return findTweenValue (0, c, 0, t*2, d, "easeOutCirc") * .5 + b;
		return findTweenValue(0, c, 0, t*2-d, d, "easeInCirc") * .5 + c*.5 + b;

	case "easeinelastic":
		// elastic (exponentially decaying sine wave) easing in
		if (t==0) return b;  if ((t/=d)==1) return b+c;  if (!p) p=d*.3;
		if (!a || a < Math.abs(c)) { a=c; var s=p/4; }
		else var s = p/(2*Math.PI) * Math.asin (c/a);
		return -(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )) + b;
	case "easeoutelastic":
		// elastic (exponentially decaying sine wave) easing out
		if (t==0) return b;  if ((t/=d)==1) return b+c;  if (!p) p=d*.3;
		if (!a || a < Math.abs(c)) { a=c; var s=p/4; }
		else var s = p/(2*Math.PI) * Math.asin (c/a);
		return (a*Math.pow(2,-10*t) * Math.sin( (t*d-s)*(2*Math.PI)/p ) + c + b);
	case "easeinoutelastic":
		// elastic (exponentially decaying sine wave) easing in/out
		if (t==0) return b;  if ((t/=d/2)==2) return b+c;  if (!p) p=d*(.3*1.5);
		if (!a || a < Math.abs(c)) { a=c; var s=p/4; }
		else var s = p/(2*Math.PI) * Math.asin (c/a);
		if (t < 1) return -.5*(a*Math.pow(2,10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )) + b;
		return (a*Math.pow(2,-10*(t-=1)) * Math.sin( (t*d-s)*(2*Math.PI)/p )*.5 + c + b);
	case "easeoutinelastic":
		// elastic (exponentially decaying sine wave) easing in/out
		if (t < d/2) return findTweenValue (0, c, 0, t*2, d, "easeOutElastic") * .5 + b;
		return findTweenValue(0, c, 0, t*2-d, d, "easeInElastic") * .5 + c*.5 + b;

	// Robert Penner's explanation for the s parameter (overshoot ammount):
	//  s controls the amount of overshoot: higher s means greater overshoot
	//  s has a default value of 1.70158, which produces an overshoot of 10 percent
	//  s==0 produces cubic easing with no overshoot
	case "easeinback":
		// back (overshooting cubic easing: (s+1)*t^3 - s*t^2) easing in - backtracking slightly, then reversing direction and moving to target
		if (s == undefined) s = 1.70158;
		return c*(t/=d)*t*((s+1)*t - s) + b;
	case "easeoutback":
		// back (overshooting cubic easing: (s+1)*t^3 - s*t^2) easing out - moving towards target, overshooting it slightly, then reversing and coming back to target
		if (s == undefined) s = 1.70158;
		return c*((t=t/d-1)*t*((s+1)*t + s) + 1) + b;
	case "easeinoutback":
		// back (overshooting cubic easing: (s+1)*t^3 - s*t^2) easing in/out - backtracking slightly, then reversing direction and moving to target, then overshooting target, reversing, and finally coming back to target
		if (s == undefined) s = 1.70158;
		if ((t/=d/2) < 1) return c/2*(t*t*(((s*=(1.525))+1)*t - s)) + b;
		return c/2*((t-=2)*t*(((s*=(1.525))+1)*t + s) + 2) + b;
	case "easeoutinback":
		// back (overshooting cubic easing: (s+1)*t^3 - s*t^2) easing out/in - moving towards middle, then overshooting it slightly, reversing, then reversing towards target, and finally coming to target
		if (t < d/2) return findTweenValue (0, c, 0, t*2, d, "easeOutBack") * .5 + b;
		return findTweenValue(0, c, 0, t*2-d, d, "easeInBack") * .5 + c*.5 + b;

	// This were changed a bit by me (since I'm not using Penner's own Math.* functions)
	// So I changed it to call findTweenValue() instead (with some different arguments)
	case "easeinbounce":
		// bounce (exponentially decaying parabolic bounce) easing in
		return c - findTweenValue (0, c, 0, d-t, d, "easeOutBounce") + b;
	case "easeoutbounce":
		// bounce (exponentially decaying parabolic bounce) easing out
		if ((t/=d) < (1/2.75)) {
			return c*(7.5625*t*t) + b;
		} else if (t < (2/2.75)) {
			return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
		} else if (t < (2.5/2.75)) {
			return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
		} else {
			return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
		}
	case "easeinoutbounce":
		// bounce (exponentially decaying parabolic bounce) easing in/out
		if (t < d/2) return findTweenValue (0, c, 0, t*2, d, "easeInBounce") * .5 + b;
		return findTweenValue(0, c, 0, t*2-d, d, "easeOutBounce") * .5 + c*.5 + b;
	case "easeoutinbounce":
		// bounce (exponentially decaying parabolic bounce) easing out/in
		if (t < d/2) return findTweenValue (0, c, 0, t*2, d, "easeOutBounce") * .5 + b;
		return findTweenValue(0, c, 0, t*2-d, d, "easeInBounce") * .5 + c*.5 + b;
	default:
		trace ("MC TWEEN ### Error on transition: there's no \""+_animType+"\" animation type.");
		return 0;
	}
};
ASSetPropFlags(_global, "findTweenValue", 1, 0);