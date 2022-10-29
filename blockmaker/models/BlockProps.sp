ArrayList g_alBlocks = null;

methodmap BlockPropManager __nullable__ {
    public BlockPropManager() {
        return view_as<BlockPropManager>(new StringMap());
    }

	public void AddBlockProp(const char[] name, const char[] value) {
		StringMap sm = view_as<StringMap>(this);
		sm.set(name, value);
	}
}
