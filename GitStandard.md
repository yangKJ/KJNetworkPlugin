# Git - Standard

## 一、分支管理
### 1.1分支模型
#### 项目-master分支
- 主分支，最稳定，功能最完整的分支，可以随时发布的代码
- 以Tag标记一个版本，因此每一个tag都对应一个线上（生产）版本
- master 分支一般由 dev 以及 fix 分支合并，<span style='color: #F56C6C;font-weight:bold'>不允在master分支直接提交代码！！</span>

#### 项目-dev分支
- dev分支始终保持功能最全、bug修复后的代码，<span style='color:#f56c6c'>未发布正式前，功能最新最全的分支</span>
- 新功能开发必须基于dev分支创建新功能的feat分支

#### 项目-feat分支
- 开发新功能（feature）由dev为基础创建的新分支
- 分支命名规则：项目-feat-功能特性，如：amway-feat-profile

#### 项目-rls分支
- 预发布分支（release），发布阶段以rls为基准发布测试代码
- 分支命名规则：项目-rls-版本号，如：amway-rls-1.0.0

> 当有一个 feat 分支开发完成，首先会合并到 dev 分支，进入提测阶段会创建 rls 分支。 如果 程中若存在 bug 需要修复，则直接由开发者在 rls 分支修复并提交。 当测试完成之后，合并 rls 分支到 master 和 dev 分支，此 master 最新代码，用作上生产版本。稳定且长期存在的分支只有 master 和 dev 分支，别的分支则在完成对应开发使命之后都会合并到这两个分支然后被删除。

#### 项目-fix分支
- 线上出现紧急bug，需要及时修复，以master分支为基础，建fix分支，修复完成后，需要合并到
master分支和dev分支
- 命名规则：项目-fix-功能特性，如：amway-fix-profile


### 1.2 gitflow 标准流程
#### 1.管理员创建git仓库，建立master分支，dev分支
> 命令行创建如下
>
> `git branch master` <br/>
> `git push -u origin master`
>
> `git branch dev` <br/>
> `git push -u origin dev`

#### 2.项目成员clone仓库，并建立自己的feat功能分支
> git clone 项目地址<br/>
> git fetch <br/>
> git checkout dev
> <br/>
> 创建本地功能分支 git checkout -b 项目-feat-功能特性
#### 3.在本地功能分支开发，<span style='color: #f56c6c'>git add, git commit &etc,注意功能模块为完成测试之前，禁止合并到dev或者master上</span>

#### 4.功能完成后可以直接合并本地的 dev 分支后 push 到远程 ，合并的时候很大几率 会发生冲突，此时需要合并代码，合并的确候确保不影响项目其他成员，如果多个人都操作了同一段代码，最好当面确认后 在进行修改。等合并完成确认无误后，删除本地 feat 开发分支
> 命令行提示 <br/>
> `git checkout dev` <br/>
> `git pull origin dev` <br/>
> `git merge 项目-feat-功能特性` <br/>
> `git push origin dev` <br/>
> `git branch -d 项目-feat-功能特性`

#### 5.发布分支：开发完成进入测试阶段，创建rls分支，准备好发布之后，合并修改至master和dev分支，删除rls分支
> `git checkout -b rls-1.00 dev` <br/>
> 合并修改至master <br/>
> `master git checkout master`  <br/>
> `git merge rls-1.00` <br/>
> `git push origin master` <br/>
> 删除rls分支 <br/>
> `git branch -d rls-1.00`

#### 6.发布版本之后，为master打上tag
> `git checkout master` <br/>
> `git tag -a 0.1 -m "Initial public release" master` <br/>
> `git push --tags`

#### 7.bug 修复分支，如果正在开发功能的同时，dev上线发现bug，或者未上线发现的bug，可以开一 个 fix 分支来修复 bug
> `git checkout -b fix-(bug-分支、特性)` <br/>
> 修复完成 <br/>
> `git checkout bug分支`  <br/>
> `git merge fix-(bug-分支、特性)` <br/>
> `git push origin bug分支` <br/>
> `git branch -d fix-(bug分支、特性)`

## 二、使用规范
### 2.1 commit规范
> commit message格式 <br/>
> `<type>(<scope>):<subject>` <br/>
> `<空行>` <br/>
> `<body>`
> <br/>
> `<空行>` <br/>
> `<footer>`

> 示例如下<br/>
> `fix(dashboard): 更新table字段`

#### type
+ fix 修补bug
+ feat 新功能(feature)
+ docs 文档(documentation)
+ style 格式，不影响代码运行的变动
+ reft 重构(refactor)，即不是新增功能，也不是修改bug的代码变动
+ test 增加测试
+ chore 构建工程或辅助工具的变动

#### scope
+ 用来说明本次Commit影响的范围，即简要说明修改会涉及的部分。

#### Subject
- 用来简要描述本次改动，概述就好了，因为后面还会在Body里列出具体信息。并且最好遵循下面三条: 
- 以动词开头，使用第一人称现在时，比如change，而不是changed或changes
- 首字母不要大写
- 结尾不用句号(.)

#### body
- 详细信息

#### footer
- 略

### 2.2
1. 团队开发时，不要使用自己单独的git分支开发，然后提交合并，正确的做法是团队基于一个公共的远程程分分支行开写作开发
2. 禁止使用 ‒force 强制推送到远端 !
3. git rebase git pull --rebase的使用
4. --no-ff --squash --fast-forward的区别