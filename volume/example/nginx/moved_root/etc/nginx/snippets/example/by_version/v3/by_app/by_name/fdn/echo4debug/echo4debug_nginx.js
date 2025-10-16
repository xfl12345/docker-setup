const theSetting = echo4debug_setting;

let itemList = [];

if (theSetting.blackList2whiteList) {
  itemList = Array.from(theSetting.blackList);
} else {
  const blackList = Array.from(theSetting.blackList ?? []);

  if (theSetting.removeAllPreset) {
    itemList = Array.from(theSetting.extras ?? []).filter((item) => {
      return !blackList.includes(item);
    });
  } else {
    const blackSet = {};
    blackList.forEach((item) => {
      blackSet[item] = true;
    });

    itemList = Array.from(echo4debug_nginx_var_list).filter((item) => {
      return !blackSet.hasOwnProperty(item);
    });

    const itemSet = {};
    itemList.forEach((item) => {
      itemSet[item] = true;
    });

    itemList = itemList.concat(
      Array.from(theSetting.extras ?? []).filter((item) => {
        return !(itemSet.hasOwnProperty(item) || blackSet.hasOwnProperty(item));
      })
    );

    // console.error("echo4debug itemList:", itemList);
  }
}

function buildNginxVars(r) {
  // console.error('echo4debug itemList:', itemList)
  return itemList
    .map((item) => {
      return `${item}=${r.variables[item] ?? ""}`;
    })
    .join("\n");
}

export default {
  buildNginxVars,
};
