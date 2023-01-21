// ==UserScript==
// @name         FoE-AutoNegotation
// @namespace    http://tampermonkey.net/
// @version      1.0
// @description  auto fill negotation suggestions from foe-helper in.
// @homepageURL  https://bitbucket.org/iso83/foe-interaction/src/master/
// @author       Iso
// @match        https://*.forgeofempires.com/game/*
// @icon         data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==
// @grant        none
// ==/UserScript==

/**
 * Simulate a key event.
 * @param {Number} keyCode The keyCode of the key to simulate
 * @param {String} type (optional) The type of event : down, up or press. The default is down
 * @param {Object} modifiers (optional) An object which contains modifiers keys { ctrlKey: true, altKey: false, ...}
 */
function simulateKey(keyCode, type, modifiers) {
	var evtName = typeof type === "string" ? "key" + type : "keydown";
	var modifier = typeof modifiers === "object" ? modifier : {};

	var event = document.createEvent("HTMLEvents");
	event.initEvent(evtName, true, false);
	event.keyCode = keyCode;

	for (var i in modifiers) {
		event[i] = modifiers[i];
	}

	document.dispatchEvent(event);
}

/**
 * Auto fill suggestions.
 */
function fillGuessesSuggestions() {
	const Guesses = Negotiation.Guesses;
	const GuessesSuggestions = Negotiation.GuessesSuggestions;

	const nextRoundSuggestion = GuessesSuggestions[Guesses.length];
	if (nextRoundSuggestion) {
		let t = 200;

		for (let place = 0; place < Negotiation.PlaceCount; place++) {
			const slotSugestion = nextRoundSuggestion[place];
			if (slotSugestion) {
				setTimeout(() => simulateKey(97 + place), t);
				t += 150;
				setTimeout(() => simulateKey(97 + (slotSugestion.id % 10)), t);
				t += 200;
			}
		}
	}
}

/**
 * Hook script on foe-helper.
 */
(function () {
	"use strict";

	setTimeout(function () {
		FoEproxy.addHandler("all", "startNegotiation", (data, postData) => {
			setTimeout(() => fillGuessesSuggestions(), 800);
		});

		FoEproxy.addHandler(
			"NegotiationGameService",
			"submitTurn",
			(data, postData) => {
				setTimeout(() => fillGuessesSuggestions(), 2000);
			}
		);

		Negotiation.CONST_Context_GBG = "bugt"; // show helper in GBG
	}, 3000);
})();