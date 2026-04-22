function getButtonElement(index) {
  return document.getElementById("buttontext" + index);
}

function hideButtons() {
  for (var i = 1; i <= 4; i++) {
    var button = getButtonElement(i);
    if (button) {
      button.style.display = "none";
    }
  }
}

function isBetwe(rep, min, max) {
  return rep >= min && rep <= max;
}

function updateButtons(options, rep) {
  document.getElementById("optionsDiv").innerHTML = "";

  /* if (!options || options.length === 0) {
    hideButtons();
    return;
  } else if (options.length <= 2) {
    document.getElementById("extraButtons").style.display = "none";
  } else if (options.length == 3) {
    document.getElementById(
      "extraButtons"
    ).innerHTML = ` <div id="buttontext3" class="text-white exter-2 px-2 rounded w-1/2 mr-2 btnss"><div class="numcontainer">3</div>Curse</div>`;
  } */

  for (let i = options.length - 1; i >= 0; i--) {
    var min = options[i].minrep;
    var max = options[i].maxrep;
    if (min != null && max != null) {
      if (!isBetwe(rep, min, max)) {
        options.splice(i, 1);
      }
    }
  }

  /* if (options.length <= 2) {
    document.getElementById("extraButtons").style.display = "none";
  } else if (options.length == 3) {
    document.getElementById(
      "extraButtons"
    ).innerHTML = ` <div id="buttontext3" class="text-white exter-2 px-2 rounded w-1/2 mr-2 btnss"><div class="numcontainer">3</div>Curse</div>`;
  } */

  let btnContent = "";
  for (var i = 0; i < options.length; i++) {
    btnContent += `<div class="_option_1w3bl_108" id="button${
      i + 1
    }"><div class="_index_1w3bl_140">${i + 1}</div>${options[i].label}</div>`;
  }

  document.getElementById("optionsDiv").innerHTML = btnContent;

  options.forEach((option, index) => {
    document
      .getElementById(`button${index + 1}`)
      .addEventListener("click", () => {
        if (option.data) {
          var d = JSON.stringify({
            event: option.event,
            args: option.args,
            type: option.type,
            requiredrep: option.requiredrep,
            data: option.data,
          });
          $.post(`https://${GetParentResourceName()}/exter-contacts:exe`, d);
          return;
        } else if (option.type === "shop") {
          var d = JSON.stringify({
            event: option.event,
            args: option.args,
            type: option.type,
            requiredrep: option.requiredrep,
            items: option.items,
          });
          $.post(`https://${GetParentResourceName()}/exter-contacts:exe`, d);
          return;
        }

        $.post(
          `https://${GetParentResourceName()}/exter-contacts:exe`,
          JSON.stringify({
            event: option.event,
            args: option.args,
            type: option.type,
            requiredrep: option.requiredrep,
          })
        );

        var body = $("body");
        body.fadeOut(700, function () {
          $.post(`https://${GetParentResourceName()}/exter-contacts:hideMenu`);
          document.getElementById("extraContent").innerHTML = "";
        });
      });
  });

  /* for (var i = 0; i < options.length; i++) {
    var button = getButtonElement(i + 1);
    if (button) {
      button.innerHTML = `<div class="numcontainer" id="button${i + 1}">${
        i + 1
      }</div>${options[i].label}`;
      button.style.display = "block";

      button.onclick = (function (option) {
        return function () {
          if (option.data) {
            var d = JSON.stringify({
              event: option.event,
              args: option.args,
              type: option.type,
              requiredrep: option.requiredrep,
              data: option.data,
            });
            $.post(`https://${GetParentResourceName()}/exter-contacts:exe`, d);
            return;
          } else if (option.type === "shop") {
            var d = JSON.stringify({
              event: option.event,
              args: option.args,
              type: option.type,
              requiredrep: option.requiredrep,
              items: option.items,
            });
            $.post(`https://${GetParentResourceName()}/exter-contacts:exe`, d);
            return;
          }

          $.post(
            `https://${GetParentResourceName()}/exter-contacts:exe`,
            JSON.stringify({
              event: option.event,
              args: option.args,
              type: option.type,
              requiredrep: option.requiredrep,
            })
          );

          var body = $("body");
          body.fadeOut(700, function () {
            $.post(
              `https://${GetParentResourceName()}/exter-contacts:hideMenu`
            );
            document.getElementById("extraContent").innerHTML = "";
          });
        };
      })(options[i]);
    }
  } */
}

function round(num, decimalPlaces = 0) {
  num = Math.round(num + "e" + decimalPlaces);
  return Number(num + "e" + -decimalPlaces);
}

function limitTo100(number) {
  return Math.min(number, 100);
}

let fullname;
let rep;
let domain;
let cart = [];
let subT = 0;
let tax = 0;
let ttoal = 0;

function updateCart(itemName, itemPrice, action) {
  const currentItem = cart.find((item) => item.name === itemName);

  if (action === "add") {
    if (currentItem) {
      currentItem.quantity += 1;
    } else {
      cart.push({ name: itemName, price: itemPrice, quantity: 1 });
    }
  } else if (action === "remove") {
    if (currentItem) {
      if (currentItem.quantity > 1) {
        currentItem.quantity -= 1;
      } else {
        cart = cart.filter((item) => item.name !== itemName);
      }
    }
  } else if (action === "delete") {
    cart = cart.filter((item) => item.name !== itemName);
  }

  updateUI(itemName);
  updateTotals();
}

function updateTotals() {
  subT = cart.reduce((total, item) => total + item.price * item.quantity, 0);
  ttoal = subT + tax;

  document.getElementById("paySub").innerHTML = subT.toFixed(2);
  document.getElementById("payTax").innerHTML = tax.toFixed(2);
  document.getElementById("payTotal").innerHTML = ttoal.toFixed(2);
}

function updateUI(itemName) {
  document
    .querySelectorAll(`div[data-item-name='${itemName}']`)
    .forEach((itemDiv) => {
      const quantityDiv = itemDiv.querySelector("._quantity_1st02_89");
      const isThatQuantDiv = itemDiv.querySelector(".isThatQuant");
      const item = cart.find((i) => i.name === itemName);

      if (item) {
        if (quantityDiv) {
          quantityDiv.textContent = item.quantity;
        }

        if (isThatQuantDiv) {
          isThatQuantDiv.style.display = "flex";
        }
      } else {
        if (isThatQuantDiv) {
          isThatQuantDiv.style.display = "none";
        }
      }
    });
}

function clearAllEventListeners() {
  const elements = document.querySelectorAll('.cartyIcon, ._minusBitch, ._plus_1st02_118, ._delete_1st02_124, #payCash');

  elements.forEach(element => {
    const clonedElement = element.cloneNode(true);
    element.parentNode.replaceChild(clonedElement, element);
  });
}

window.addEventListener("message", function (event) {
  if (event.data.type === "open") {
    if (event.data.ui == 1) {
      this.document
        .getElementById("optionsDiv")
        .style.removeProperty("display");

      this.document
        .getElementById("nglThisshitdope")
        .style.removeProperty("display");

      document.getElementById("main").style.position = "absolute";

      document.getElementById("itemsStore").style.display = "none";

      document.body.style.display = "block";

      //Hide the tablet part just in case
      document.getElementsByClassName("contacts-container")[0].style.display =
        "none";
      document.getElementById("BD").style.display = "none";
      // document.body.style.removeProperty("display");

      fullname = event.data.name.toUpperCase();
      rep = round(parseFloat(event.data.rep), 2);
      domain = event.data.domain;

      document.getElementById(
        "guyName"
      ).innerHTML = `<span class="_big_1w3bl_59">${
        fullname.split(" ")[0]
      }</span> ${fullname.split(" ")[1]}`;

      document.getElementById(
        "guyName2"
      ).innerHTML = `<span class="_big_1w3bl_59">${
        fullname.split(" ")[0]
      }</span> ${fullname.split(" ")[1]}`;

      document.getElementById("guyDomain").innerText = domain;
      document.getElementById("guyRep").innerText = rep + " REP";

      document.getElementById("mainText").innerText = event.data.text;

      //document.body.style.display = "block";
      document.getElementById("main").style.display = "flex";

      updateButtons(event.data.options, rep);
    } else {
      document.body.style.display = "block";
      document.getElementById("main").style.display = "none";
      document.getElementById("itemsStore").style.display = "none";

      const table = (document.getElementById("npcShit").innerHTML = "");

      let totalR = 0;
      let totalRPool = event.data.final.length * 100; //assuming that 100 is the max rep for each NPC

      let mostCRep = 0;
      let mostRGuy = "None";
      let content = "";
      event.data.final.forEach((npc, index) => {
        let r = round(parseFloat(npc.reputation), 2);
        totalR += round(parseFloat(npc.reputation), 2);

        if (mostCRep <= r) {
          mostCRep = r;
          mostRGuy = npc.name;
        }
        /* // <div class="avatar" style="background-image: url('https://assets.nopixel.net/dev/images/contacts/${String(npc.domain)
          .toLowerCase()
          .replace(/\s+/g, "_")
          .replace(
            "'",
            "")}.webp'); max-width: 80%; max-height: 80%;"></div> */
        let vvv = npc.domain
          .toLowerCase()
          .replace(/\s+/g, "_")
          .replace("'", "");

        content += `<tr>
          <td >
            <div class="avatar" style="background-image: url('./dist/avatars/${vvv}.webp');"></div>
            </td>
            <td class="name">${npc.name}</td>
            <td class="exter-2"><div class="tag bg-gray-200 text-gray-600 px-4 exter-2 rounded">${
              npc.domain
            }</div></td>
            <td class="exter-2">
                <div class="rep-bar-container">
                    <div class="bar bg-gray-200 h-4 w-64 rounded overflow-hidden">
                        <div class="bar-progress bg-green-500 h-full" style="width:${limitTo100(
                          npc.reputation
                        )}%;"></div>
                    </div>
                </div>
            </td>
            <td class="gps">
              <div class="markButton" id="markButton_${index}" data-x="${
          npc.coords.x
        }" data-y="${npc.coords.y}">Set mark</div>
            </td>
         </tr>`;
      });

      document.getElementById("npcShit").innerHTML = content;

      document.getElementById("MRGuyName").innerHTML = mostRGuy;
      document.getElementById("mostCRep").innerHTML = mostCRep + "/100";

      document.getElementById("mostCRepBar").style.width = `${limitTo100(
        mostCRep
      )}%`;

      document.getElementById("totalR").innerHTML = totalR + "/" + totalRPool;
      document.getElementById("totalRBar").style.width = `${limitTo100(
        (totalR / totalRPool) * 100
      )}%`;

      event.data.final.forEach((npc, index) => {
        let markButton = document.getElementById(`markButton_${index}`);
        if (markButton) {
          markButton.addEventListener("click", function () {
            let x = markButton.getAttribute("data-x");
            let y = markButton.getAttribute("data-y");

            $.post(
              `https://${GetParentResourceName()}/exter-contacts:setMark`,
              JSON.stringify({ x, y })
            );

            var body = $("body");
            body.fadeOut(700, function () {
              $.post(
                `https://${GetParentResourceName()}/exter-contacts:hideMenu`
              );
              document.getElementById("extraContent").innerHTML = "";
            });
          });
        }
      });

      document
        .getElementById("searchInput")
        .addEventListener("input", function () {
          let filter = this.value.toLowerCase();
          let contacts = document.querySelectorAll("#npcShit tr");

          contacts.forEach((contact) => {
            let name = contact.querySelector(".name").innerText.toLowerCase();
            if (name.includes(filter)) {
              contact.style.display = "";
            } else {
              contact.style.display = "none";
            }
          });
        });
      document.getElementById("BD").style.display = "flex";
      //openRep Tablet
      document.getElementsByClassName("contacts-container")[0].style.display =
        "flex";
      const buttons = document.querySelectorAll("._btn_vcubc_38");

      buttons.forEach((button) => {
        button.addEventListener("click", (event) => {
          var body = $("body");
          body.fadeOut(700, function () {
            $.post(
              `https://${GetParentResourceName()}/exter-contacts:hideMenu`
            );
            document.getElementById("extraContent").innerHTML = "";
          });
        });
      });
    }
  } else if (event.data.type === "add") {
    //this.document.getElementById("optionsDiv").style.removeProperty("display");

    updateButtons(event.data.options);

    let oldData = document.getElementById("extraContent").innerHTML;
    document.getElementById("extraContent").innerHTML =
      oldData +
      `<div class="mt-2 rounded mb-5" style="background: radial-gradient(87.66% 87.66% at 50% 50%, rgba(255, 255, 255, 0.16) 0%, rgba(255, 255, 255, 0.00) 100%)"><div class="icon-container"><img class="icon" src="./dist/miniicon.png" alt=""></div><div class="p-4"><p class="text-cool text-sm">${event.data.text}</p></div></div>`;

    document.getElementById("extraContent").innerHTML =
      oldData +
      `<div class="flex w-full flex-row items-center justify-start gap-[1vh]">
                            <span class="_dialogueText_1w3bl_78"><span class="_big_1w3bl_59">${
                              fullname.split(" ")[0]
                            }</span> ${fullname.split(" ")[1]}</span>
                            <div class="_tag_1w3bl_62">${domain}</div>
                        </div>
      <div class="_textBox_1w3bl_90"><svg width="0.83vh" height="0.83vh" viewBox="0 0 9 9" fill="none"
                                xmlns="http://www.w3.org/2000/svg" class="_indicator_1w3bl_103">
                                <path d="M0 0H9L4.5 4.5L0 9V0Z" fill="url(#paint0_radial_3202_976)"></path>
                                <defs>
                                    <radialGradient id="paint0_radial_3202_976" cx="0" cy="0" r="1"
                                        gradientUnits="userSpaceOnUse"
                                        gradientTransform="translate(4.5 4.5) rotate(45) scale(8.48528)">
                                        <stop stop-color="#00F8B9"></stop>
                                        <stop offset="1" stop-color="#00F8B9" stop-opacity="0"></stop>
                                    </radialGradient>
                                </defs>
                            </svg>
                            <span id="mainText" class="whitespace-pre-line">${
                              event.data.text
                            }</span>
                        </div>`;
  } else if (event.data.type === "shop") {
    // document.getElementById("mainText").innerText =
    //   "Here is what I got for you now";

    cart = [];
    subT = 0;
    tax = 0;
    ttoal = 0;

    this.document.getElementById("optionsDiv").style.display = "none";
    this.document.getElementById("nglThisshitdope").style.display = "none";

    document.getElementById("main").style.position = "fixed";

    this.document.getElementById("itemsStore").style.removeProperty("display");

    this.document.getElementById("paySub").innerHTML = subT;
    this.document.getElementById("payTax").innerHTML = tax;
    this.document.getElementById("payTotal").innerHTML = ttoal;

    this.document.getElementById("stupidItemsList").innerHTML = "";

    let items = event.data.items;

    let itemsList = items
      .map((item) => {
        return `<div class="_item_1st02_1" data-item-name="${item.name}" data-item-price="${item.price}"
    data-item-rep="${item.requiredrep}">
    <div class="_top_1st02_45">
        <div class="_header_1st02_58"><svg width="0.83vh" height="0.83vh" viewBox="0 0 9 9" fill="none"
                xmlns="http://www.w3.org/2000/svg">
                <path d="M0 0H9L4.5 4.5L0 9V0Z" fill="url(#paint0_radial_218_224)"></path>
                <defs>
                    <radialGradient id="paint0_radial_218_224" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse"
                        gradientTransform="translate(4.5 4.5) rotate(45) scale(8.48528)">
                        <stop stop-color="#00F8B9"></stop>
                        <stop offset="1" stop-color="#00F8B9" stop-opacity="0"></stop>
                    </radialGradient>
                </defs>
            </svg>
            <div class="_price_container_1st02_67">
                <div class="_text_1st02_74">$${item.price}</div>
            </div>
        </div>
        <div class="_image_1st02_82" style="background-image: url(${item.img});">
        </div>
        <div class="isThatQuant mt-[-1.5vh] flex w-full flex-row items-center justify-between gap-[1vh] pl-[1vh] pr-[1vh]"
            style="width: 90%;margin: auto;margin-bottom: 10%;height: 4%; display: none;">
            <div class="_button_1st02_104 _minusBitch"><svg width="0.648vh" height="0.185vh" viewBox="0 0 7 2" fill="none"
                    xmlns="http://www.w3.org/2000/svg">
                    <rect width="7" height="2" fill="white"></rect>
                </svg></div>
            <div class="_quantity_1st02_89">2</div>
            <div class="_button_1st02_104 _plus_1st02_118"><svg width="0.74vh" height="0.74vh" viewBox="0 0 8 8"
                    fill="none" xmlns="http://www.w3.org/2000/svg">
                    <rect y="3" width="8" height="2" fill="#00F8B9"></rect>
                    <rect x="5" width="8" height="2" transform="rotate(90 5 0)" fill="#00F8B9"></rect>
                </svg></div>
            <div class="_button_1st02_104 _delete_1st02_124"><svg width="0.83vh" height="1.018vh" viewBox="0 0 9 11"
                    fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path fill-rule="evenodd" clip-rule="evenodd"
                        d="M3.21429 0.343815V0.68763H1.60714H0V1.37526V2.06289H4.5H9V1.37526V0.68763H7.39286H5.78571V0.343815V0H4.5H3.21429V0.343815ZM0.642857 6.27862C0.642857 10.1667 0.635464 9.93082 0.766286 10.2155C0.921234 10.5526 1.16715 10.7898 1.5067 10.9294L1.65737 10.9913L4.44795 10.9971C7.564 11.0035 7.33614 11.0141 7.65402 10.8484C7.88946 10.7257 8.09697 10.5032 8.21373 10.2481C8.36815 9.91073 8.35714 10.2155 8.35714 6.28086V2.75052H4.5H0.642857V6.27862Z"
                        fill="#B94141"></path>
                </svg></div>
        </div>
    </div>
    <div class="_bottom_1st02_48">
        <div class="flex w-full flex-row items-center justify-between pl-5 pr-1">
            <div class="flex flex-col items-start justify-center">
                <div class="_title_1st02_140">${item.label}</div>
                <div class="_category_1st02_148">${item.description}</div>
            </div>
            <div class="cartyIcon _button_1st02_104"><svg width="1.66vh" height="1.38vh" viewBox="0 0 18 15" fill="none"
                    xmlns="http://www.w3.org/2000/svg"
                    style="filter: drop-shadow(rgba(0, 248, 185, 0.55) 0px 0.37vh 0.43vh);">
                    <path fill-rule="evenodd" clip-rule="evenodd"
                        d="M0.42543 0.0985138C-0.0279661 0.329503 -0.139723 0.883041 0.191114 1.25915C0.404599 1.50183 0.462307 1.51237 1.57963 1.51325C2.20471 1.51374 2.63491 1.52891 2.73467 1.55395C2.93391 1.60404 3.10608 1.76475 3.18096 1.97059C3.21259 2.05751 3.74639 3.85131 4.36714 5.9568C5.03839 8.23357 5.54302 9.8846 5.61237 10.0308C5.88434 10.6042 6.38028 11.0085 7.04114 11.1955C7.25596 11.2563 7.4837 11.26 10.9464 11.26C15.0168 11.26 14.7836 11.2727 15.3097 11.0232C15.6971 10.8394 16.0842 10.4672 16.2685 10.101C16.3407 9.95768 16.727 8.80109 17.1952 7.32651L17.9981 4.79781L17.9998 4.44587C18.0015 4.11668 17.994 4.07864 17.8851 3.85777C17.6558 3.39295 17.2315 3.08701 16.7257 3.02193C16.5953 3.00514 13.9199 2.99088 10.7804 2.99025L5.07227 2.98909L4.98511 2.69935C4.93719 2.54 4.83402 2.19428 4.7559 1.93112C4.67778 1.66792 4.58214 1.37874 4.54337 1.28848C4.3164 0.760013 3.79091 0.301301 3.18747 0.104906C2.95516 0.0293258 2.87518 0.0240579 1.77995 0.0123978L0.618752 0L0.42543 0.0985138ZM8.0504 12.0171C7.92661 12.0318 7.74416 12.0917 7.58691 12.1693C6.58264 12.6647 6.47075 14.0672 7.38345 14.7196C8.13299 15.2553 9.18866 14.9959 9.59448 14.1763C9.89537 13.5687 9.77869 12.8846 9.29567 12.4248C8.93855 12.0848 8.55063 11.9578 8.0504 12.0171ZM13.2864 12.0214C12.661 12.105 12.1428 12.6226 12.0306 13.2756C11.9199 13.92 12.2792 14.5732 12.9078 14.8704C13.1284 14.9747 13.1724 14.9828 13.5151 14.9828C13.8578 14.9828 13.9018 14.9747 14.1224 14.8704C14.7511 14.5732 15.1103 13.92 14.9996 13.2754C14.9248 12.84 14.7065 12.4978 14.3538 12.2626C14.03 12.0468 13.6829 11.9684 13.2864 12.0214Z"
                        fill="#00F8B9"></path>
                </svg></div>
        </div>
        <div class="_line_1st02_48"></div>
    </div>
</div>
`;
      })
      .join("");

    document.getElementById("stupidItemsList").innerHTML = `${itemsList}`;

    document.querySelectorAll(".cartyIcon").forEach((button) => {
      button.addEventListener("click", function () {
        const itemDiv = this.closest("._item_1st02_1");
        const itemName = itemDiv.dataset.itemName;
        const itemPrice = parseInt(itemDiv.dataset.itemPrice);
        updateCart(itemName, itemPrice, "add");
      });
    });
    
    document.querySelectorAll("._minusBitch").forEach((button) => {
      button.addEventListener("click", function () {
        const itemDiv = this.closest("._item_1st02_1");
        const itemName = itemDiv.dataset.itemName;
        updateCart(itemName, null, "remove");
      });
    });
    
    document.querySelectorAll("._plus_1st02_118").forEach((button) => {
      button.addEventListener("click", function () {
        const itemDiv = this.closest("._item_1st02_1");
        const itemName = itemDiv.dataset.itemName;
        const itemPrice = parseInt(itemDiv.dataset.itemPrice);
        updateCart(itemName, itemPrice, "add");
      });
    });
    
    document.querySelectorAll("._delete_1st02_124").forEach((button) => {
      button.addEventListener("click", function () {
        const itemDiv = this.closest("._item_1st02_1");
        const itemName = itemDiv.dataset.itemName;
        updateCart(itemName, null, "delete");
      });
    });
    
    this.document
      .getElementById("payCash")
      .addEventListener("click", function () {
        $.post(
          `https://${GetParentResourceName()}/buyItem`,
          JSON.stringify({ cart })
        );
      });

  } else if (event.data.type === "hide") {
    document.getElementById("extraContent").innerHTML = "";
    document.getElementsByClassName("contacts-container")[0].style.display =
      "none";
    document.getElementById("BD").style.display = "none";
    document.getElementById("main").style.display = "none";
    document.body.style.display = "none";
    clearAllEventListeners()
  }
});

document.addEventListener("keydown", function (event) {
  var keyPressed = event.key;
  switch (keyPressed) {
    case "Escape":
      var body = $("body");
      body.fadeOut(700, function () {
        $.post(`https://${GetParentResourceName()}/exter-contacts:hideMenu`);
        document.getElementById("extraContent").innerHTML = "";
      });
      clearAllEventListeners()
      break;
  }
});

function clickButton(buttonIndex) {
  var button = getButtonElement(buttonIndex);
  if (button && button.style.display !== "none") {
    button.click();
  }
}





