package modifytags

import (
	"errors"
	"fmt"
	"time"
)

var ErrNotOnAnyBranch = errors.New("git: not on any branch")

type NotInstalled struct {
	message string
	err     error
}

type PullRequest struct {
	ID                  string `json:"id"`
	Number              int    `json:"number"`
	Title               string `json:"title"`
	State               string
	Closed              bool       `json:"closed"`
	URL                 string     `xml:"url" json:"url"`
	BaseRefName         string     `xml:"base_ref_name" json:"base_ref_name"`
	HeadRefName         string     `xml:"head_ref_name" json:"head_ref_name"`
	HeadRefOid          string     `json:"head_ref_oid"`
	Body                string     `json:"body"`
	Mergeable           string     `json:"mergeable"`
	Additions           int        `json:"additions"`
	Deletions           int        `json:"deletions"`
	ChangedFiles        int        `json:"changed_files"`
	MergeStateStatus    string     `json:"merge_state_status"`
	IsInMergeQueue      bool       `json:"is_in_merge_queue"`
	IsMergeQueueEnabled bool       `json:"is_merge_queue_enabled"`
	CreatedAt           time.Time  `json:"created_at"`
	UpdatedAt           time.Time  `json:"updated_at"`
	ClosedAt            *time.Time `json:"closed_at"`
	MergedAt            *time.Time `json:"merged_at"`

	Files struct {
		Nodes     []string   `json:"nodes"`
		CreatedAt time.Time  `json:"created_at"`
		UpdatedAt time.Time  `json:"updated_at"`
		ClosedAt  *time.Time `json:"closed_at"`
		MergedAt  *time.Time `json:"merged_at"`
	} `json:"files"`
}

func (e *NotInstalled) Error() string {
	return e.message
}

func (e *NotInstalled) Unwrap() error {
	return e.err
}

type GitError struct {
	ExitCode int
	Stderr   string
	err      error
}

func (ge *GitError) Error() string {
	if ge.Stderr == "" {
		return fmt.Sprintf("failed to run git: %v", ge.err)
	}
	return fmt.Sprintf("failed to run git: %s", ge.Stderr)
}

func (ge *GitError) Unwrap() error {
	return ge.err
}
